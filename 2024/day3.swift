import Foundation
import RegexBuilder

let filename = "input/day3.txt"

func readFile() -> String {
    return try! String(contentsOfFile: filename)
}

let mulPattern = Regex {
    "mul("
    Capture {
        OneOrMore(.digit)
    } transform: {
        Int($0)!
    }
    ","
    Capture {
        OneOrMore(.digit)
    } transform: {
        Int($0)!
    }
    ")"
}

let codePattern = Regex {
    ChoiceOf {
        "do()"
        "don't()"
        mulPattern
    }
}

func part1() -> Int {
    return readFile().matches (of: mulPattern).map {
        $0.1 * $0.2
    }.reduce(0, +)
}

func part2() -> Int {
    var enabled = true
    var sum = 0

    readFile().matches (of: codePattern).forEach {
        switch $0.0 {
            case "do()":
                enabled = true
            case "don't()":
                enabled = false
            default:
                if enabled {
                    sum += $0.1! * $0.2!
                }
        }
    }

    return sum
}

print(part1())
print(part2())
