import Foundation
import RegexBuilder

let filename = "input/day5.txt"

let rulePattern = Regex {
    Capture {
        OneOrMore(.digit)
    } transform: {
        Int($0)!
    }
    "|"
    Capture {
        OneOrMore(.digit)
    } transform: {
        Int($0)!
    }
}

let listPattern = Regex {
    Capture {
        OneOrMore {
            OneOrMore {
                .digit
            }
            ","
        }
        OneOrMore {
            .digit
        }
    } transform: {
        $0.split(separator: ",").map { Int(String($0))! }
    }
}

struct Rule {
    let before: Int
    let after: Int
}

func readFile() -> (rules: [Rule], lists: [[Int]]) {
    let contents = try! String(contentsOfFile: filename)
    let rules = contents.matches(of: rulePattern).map { Rule(before: $0.1, after: $0.2) }
    let lists = contents.matches(of: listPattern).map(\.1)
    return (rules: rules, lists: lists)
}

func isValid(list: [Int], rules: [Rule]) -> Bool {
    rules.filter {
        list.contains($0.before) && list.contains($0.after)
    }.allSatisfy {
        list.firstIndex(of: $0.before)! < list.firstIndex(of: $0.after)!
    }
}

func fixList(list: [Int], rules: [Rule]) -> [Int] {
    let matchingRules = rules.filter {
        list.contains($0.before) && list.contains($0.after)
    }

    var fixedList = list
    var swap = true

    while swap {
        swap = false

        for rule in matchingRules {
            let before = fixedList.firstIndex(of: rule.before)!
            let after = fixedList.firstIndex(of: rule.after)!

            if before > after {
                fixedList.swapAt(before, after)
                swap = true
            }
        }
    }

    return fixedList
}

func part1() -> Int {
    let input = readFile()

    return input.lists.filter {
        isValid(list: $0, rules: input.rules)
    }.map {
        $0[$0.count / 2]
    }.reduce(0, +)
}

func part2() -> Int {
    let input = readFile()

    return input.lists.filter {
        !isValid(list: $0, rules: input.rules)
    }.map {
        fixList(list: $0, rules: input.rules)
    }.map {
        $0[$0.count / 2]
    }.reduce(0, +)
}

print(part1())
print(part2())
