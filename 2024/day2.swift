import Foundation
import RegexBuilder

let filename = "input/day2.txt"

func readFile() -> [[Int]] {
    let contents = try! String(contentsOfFile: filename)

    return contents.split(separator: "\n").map { line in
        line.matches(of: OneOrMore(.digit)).map { Int($0.0)! }
    }
}

func validateReport(_ levels: [Int], validate: (Int, Int) -> Bool) -> Bool {
    var previousLevel = levels[0]

    for level in levels[1...] {
        if !validate(previousLevel, level) {
            return false
        }

        previousLevel = level
    }

    return true
}

func validateReportWithDampener(_ levels: [Int], _ validate: (Int, Int) -> Bool) -> Bool {
    for i in 0 ..< levels.count {
        if validateReport(Array(levels[..<i] + levels[(i + 1)...]), validate: validate) {
            return true
        }
    }

    return false
}

func part1() -> Int {
    return readFile().filter { report in
        validateReport(report) { (1 ... 3).contains($0 - $1) } || validateReport(report) { (1 ... 3).contains($1 - $0) }
    }.count
}

func part2() -> Int {
    return readFile().filter { report in
        validateReportWithDampener(report) { (1 ... 3).contains($0 - $1) } || validateReportWithDampener(report) { (1 ... 3).contains($1 - $0) }
    }.count
}

print(part1())
print(part2())
