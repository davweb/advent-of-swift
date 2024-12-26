import Foundation
import RegexBuilder

let filename = "input/day25.txt"

let gridPattern = Regex {
    Capture {
        Repeat(count: 5) {
            Repeat(count: 5) {
                ChoiceOf {
                    "#"
                    "."
                }
            }
            "\n"
        }
    } transform: {
        parseGrid(String($0))
    }
}

let keyPattern = Regex {
    ".....\n"
    gridPattern
}

let lockPattern = Regex {
    "#####\n"
    gridPattern
}

func parseGrid(_ match: String) -> [Int] {
    let lines = match.split(separator: "\n")
    var result = Array(repeating: 0, count: 5)

    for line in lines {
        for (x, char) in line.enumerated() {
            if char == "#" {
                result[x] += 1
            }
        }
    }

    return result
}

func readFile() -> (locks: [[Int]], keys: [[Int]]) {
    let contents = try! String(contentsOfFile: filename, encoding: .utf8)
    let keys = contents.matches(of: keyPattern).map(\.1)
    let locks = contents.matches(of: lockPattern).map(\.1)
    return (locks: locks, keys: keys)
}

func fit(lock: [Int], key: [Int]) -> Bool {
    zip(lock, key).allSatisfy { $0.0 + $0.1 < 6 }
}

func part1() -> Int {
    let (locks, keys) = readFile()

    return locks.flatMap { lock in
        keys.filter { fit(lock: lock, key: $0) }
    }.count
}

print(part1())
