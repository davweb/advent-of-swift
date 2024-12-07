import Foundation

let filename = "input/day7.txt"

struct Equation {
    let solution: Int
    let numbers: [Int]
}

func readFile() -> [Equation] {
    let contents = try! String(contentsOfFile: filename)
    let lines = contents.split(separator: "\n")

    return lines.map {
        let pair = $0.split(separator: ": ")

        return Equation(
            solution: Int(pair[0])!,
            numbers: pair[1].split(separator: " ").map { Int($0)! }
        )
    }
}

func solve(_ equation: Equation) -> Bool {
    if equation.numbers.count == 1 {
        return equation.numbers[0] == equation.solution
    }

    let nextNumbers = Array(equation.numbers.dropLast())
    let added = Equation(solution: equation.solution - equation.numbers.last!, numbers: nextNumbers)
    let multiplied = Equation(solution: equation.solution / equation.numbers.last!, numbers: nextNumbers)

    return solve(added) || (equation.solution % equation.numbers.last! == 0 && solve(multiplied))
}

func concatenate(_ x: Int, _ y: Int) -> Int {
    var a = 10

    while a < y {
        a *= 10
    }

    return x * a + y
}

func calculate(_ numbers: [Int]) -> [Int] {
    if numbers.count == 1 {
        return numbers
    }

    let added = [numbers[0] + numbers[1]] + numbers[2...]
    let multiplied = [numbers[0] * numbers[1]] + numbers[2...]
    let concatenated = [concatenate(numbers[0], numbers[1])] + numbers[2...]

    return calculate(added) + calculate(multiplied) + calculate(concatenated)
}

func part1() -> Int {
    return readFile().filter(solve).map(\.solution).reduce(0, +)
}

func part2() -> Int {
   return readFile().filter { calculate($0.numbers).contains($0.solution) }.map(\.solution).reduce(0, +)
}

print(part1())
print(part2())
