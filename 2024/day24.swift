import Foundation
import RegexBuilder

let filename = "input/day24.txt"

enum Operation {
    case and
    case or
    case xor
}

struct Gate {
    let input1: String
    let input2: String
    let operation: Operation
    let output: String
}

let inputsPattern = Regex {
    Capture {
        ChoiceOf {
            "x"
            "y"
        }
        Repeat(2 ... 2) {
            .digit
        }
    } transform: {
        String($0)
    }
    ": "
    Capture {
        ChoiceOf {
            "0"
            "1"
        }
    } transform: {
        Int($0)!
    }
}

let wirePattern = Regex {
    Capture {
        OneOrMore {
            .word.union(.digit)
        }
    } transform: {
        String($0)
    }
}

let wiresPattern = Regex {
    wirePattern
    " "
    Capture {
        ChoiceOf {
            "XOR"
            "AND"
            "OR"
        }
    } transform: {
        $0 == "AND" ? Operation.and : $0 == "OR" ? Operation.or : Operation.xor
    }
    " "
    wirePattern
    " -> "
    wirePattern
}

func readFile() -> (inputs: [String: Int], gates: [Gate]) {
    let contents = try! String(contentsOfFile: filename, encoding: .utf8)
    let inputs = Dictionary(uniqueKeysWithValues: contents.matches(of: inputsPattern).map { ($0.1, $0.2) })

    let gates = contents.matches(of: wiresPattern).map { Gate(
        input1: $0.1,
        input2: $0.3,
        operation: $0.2,
        output: $0.4
    ) }

    return (inputs: inputs, gates: gates)
}

func process(initialValues: [String: Int], gates: [Gate]) -> [String: Int] {
    var values = initialValues
    var previousCount = -1
    var outputs = Set<String>()

    while outputs.count != previousCount {
        previousCount = outputs.count

        for gate in gates {
            if let a = values[gate.input1], let b = values[gate.input2] {
                values[gate.output] = switch gate.operation {
                case .and:
                    a & b
                case .or:
                    a | b
                case .xor:
                    a ^ b
                }
                outputs.insert(gate.output)
            }
        }
    }

    return values
}

func swapOutputs(gates: [Gate], output1: String, output2: String) -> [Gate] {
    gates.map {
        if $0.output == output1 {
            return Gate(input1: $0.input1, input2: $0.input2, operation: $0.operation, output: output2)
        }

        if $0.output == output2 {
            return Gate(input1: $0.input1, input2: $0.input2, operation: $0.operation, output: output1)
        }

        return $0
    }
}

func findGate(gates: [Gate], input1: String, input2: String? = nil, operation: Operation, output: String? = nil) -> Gate? {
    gates.filter {
        if $0.operation != operation {
            return false
        }

        if output != nil && $0.output != output {
            return false
        }

        if input2 == nil {
            return $0.input1 == input1 || $0.input2 == input1
        }

        return ($0.input1 == input1 && $0.input2 == input2) || ($0.input1 == input2 && $0.input2 == input1)
    }.first
}

// Find a half adder for a bit in the circuit
func halfAdder(gates: [Gate], bit: Int) -> String? {
    let xInput = "x" + String(format: "%02d", bit)
    let yInput = "y" + String(format: "%02d", bit)
    let zOutput = "z" + String(format: "%02d", bit)

    let gate1 = findGate(gates: gates, input1: xInput, input2: yInput, operation: .xor, output: zOutput)

    if gate1 == nil {
        fatalError("half adder gate1 not found for bit \(bit)")
    }

    let gate2 = findGate(gates: gates, input1: xInput, input2: yInput, operation: .and)

    if gate2 == nil {
        fatalError("half adder gate2 not found for bit \(bit)")
    }

    return gate2!.output
}

// recursively find full adders, making changes to the circuit as needed
func fullAdders(gates: [Gate], bit: Int, carryIn: String, swapped: [String]) -> [String]! {
    let xInput = "x" + String(format: "%02d", bit)
    let yInput = "y" + String(format: "%02d", bit)
    let zOutput = "z" + String(format: "%02d", bit)

    let gate1 = findGate(gates: gates, input1: xInput, input2: yInput, operation: .xor)

    if gate1 == nil {
        return nil
    }

    let gate2 = findGate(gates: gates, input1: xInput, input2: yInput, operation: .and)

    if gate2 == nil {
        return nil
    }

    let gate3 = findGate(gates: gates, input1: carryIn, input2: gate1!.output, operation: .xor, output: zOutput)

    if gate3 == nil {
        var swaps = [(String, String)]()

        if let gate = findGate(gates: gates, input1: carryIn, operation: .xor, output: zOutput) {
            if gate.input1 == carryIn {
                swaps.append((gate.input2, gate1!.output))
            } else {
                swaps.append((gate.input1, gate1!.output))
            }
        }

        if let gate = findGate(gates: gates, input1: gate1!.output, operation: .xor, output: zOutput) {
            if gate.input1 == gate1!.output {
                swaps.append((gate.input2, carryIn))
            } else {
                swaps.append((gate.input1, carryIn))
            }
        }

        if let gate = findGate(gates: gates, input1: carryIn, input2: gate1!.output, operation: .xor) {
            swaps.append((gate.output, zOutput))
        }

        for swap in swaps {
            let newGates = swapOutputs(gates: gates, output1: swap.0, output2: swap.1)
            let result = fullAdders(gates: newGates, bit: bit, carryIn: carryIn, swapped: swapped + [swap.0, swap.1])

            if result != nil {
                return result
            }
        }

        return nil
    }

    let gate4 = findGate(gates: gates, input1: carryIn, input2: gate1!.output, operation: .and)

    if gate4 == nil {
        return nil
    }

    let gate5 = findGate(gates: gates, input1: gate2!.output, input2: gate4!.output, operation: .or)

    if gate5 == nil {
        return nil
    }

    let carryOut = gate5!.output

    if bit == 44 {
        return swapped
    }

    return fullAdders(gates: gates, bit: bit + 1, carryIn: carryOut, swapped: swapped)
}

func part1() -> Int {
    let (initialValues, gates) = readFile()
    let values = process(initialValues: initialValues, gates: gates)

    return values.filter { $0.key.starts(with: "z") }.sorted { $0.key > $1.key }.reduce(0) { total, entry in
        total * 2 + entry.value
    }
}

func part2() -> String {
    let (_, gates) = readFile()
    let carryOut = halfAdder(gates: gates, bit: 0)!
    return fullAdders(gates: gates, bit: 1, carryIn: carryOut, swapped: [String]())!.sorted().joined(separator: ",")
}

print(part1())
print(part2())
