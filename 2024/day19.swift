import Foundation
import RegexBuilder

let filename = "input/day19.txt"

let coloursPattern = Regex {
    Capture {
        OneOrMore {
            ChoiceOf {
                "w"
                "u"
                "b"
                "r"
                "g"
            }
        }
    } transform: {
        String($0)
    }
}

let towelsPattern = Regex {
    Capture {
        OneOrMore {
            coloursPattern
            ", "
        }
        coloursPattern
    } transform: {
        $0.split(separator: ", ").map { String($0) }
    }
}

let designPattern = Regex {
    Anchor.startOfLine
    coloursPattern
    Anchor.endOfLine
}

func readFile() -> (towels: [String], designs: [String]) {
    let contents = try! String(contentsOfFile: filename, encoding: .utf8)
    let towels = contents.firstMatch(of: towelsPattern)!.1
    let designs = contents.matches(of: designPattern).map(\.1)
    return (towels: towels, designs: designs)
}

var cache = [String: Int]()

func countDesigns(towels: [String], design: String) -> Int {
    if let cachedCount = cache[design] {
        return cachedCount
    }

    let count = towels.filter { design.starts(with: $0) }.map { towel in
        var nextDesign = design
        nextDesign.removeFirst(towel.count)
        return nextDesign.isEmpty ? 1 : countDesigns(towels: towels, design: nextDesign)
    }.reduce(0, +)

    cache[design] = count
    return count
}

func part1() -> Int {
    let (towels, designs) = readFile()
    return designs.filter { countDesigns(towels: towels, design: $0) != 0 }.count
}

func part2() -> Int {
    let (towels, designs) = readFile()
    return designs.map { countDesigns(towels: towels, design: $0) }.reduce(0, +)
}

print(part1())
print(part2())
