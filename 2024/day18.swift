import Foundation
import RegexBuilder

let filename = "input/day18.txt"

let width = 71
let height = 71

let number = Regex {
    Capture {
        OneOrMore(.digit)
    } transform: {
        Int($0)!
    }
}

let bytePattern = Regex {
    number
    ","
    number
}

struct Location: Hashable {
    let x: Int
    let y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

func readFile() -> [Location] {
    let contents = try! String(contentsOfFile: filename, encoding: .utf8)
    return contents.matches(of: bytePattern).map { Location($0.1, $0.2) }
}

func neighbours(_ location: Location) -> [Location] {
    [
        Location(location.x - 1, location.y),
        Location(location.x + 1, location.y),
        Location(location.x, location.y - 1),
        Location(location.x, location.y + 1),
    ].filter {
        (0 ..< width).contains($0.x) && (0 ..< height).contains($0.y)
    }
}

func shortestPath(_ grid: Set<Location>) -> Int? {
    var historian: Location? = Location(0, 0)
    var distances = [historian!: 0]
    let end = Location(width - 1, height - 1)
    var visited = Set<Location>()

    while historian != nil {
        let distance = distances[historian!]! + 1

        neighbours(historian!).filter {
            !visited.contains($0) && !grid.contains($0) && (distances[$0] == nil || distances[$0]! > distance)
        }.forEach {
            distances[$0] = distance
        }

        visited.insert(historian!)

        historian = distances.filter {
            !visited.contains($0.key)
        }.sorted {
            $0.value < $1.value
        }.first?.key
    }

    return distances[end]
}

func binarySearch(lowerBound: Int = 0, upperBound: Int, calc: (Int) -> Bool) -> Int {
    var low = lowerBound
    var high = upperBound

    while high - low > 1 {
        let mid = (low + high) / 2

        if calc(mid) {
            high = mid
        } else {
            low = mid
        }
    }

    return high
}

func part1() -> Int {
    let bytes = readFile()
    let grid = Set<Location>(bytes[0 ... 1023])
    return shortestPath(grid)!
}

func part2() -> Location {
    let bytes = readFile()

    let index = binarySearch(lowerBound: 1023, upperBound: bytes.count - 1) {
        let grid = Set<Location>(bytes[0 ... $0])
        return shortestPath(grid) == nil
    }

    return bytes[index]
}

print(part1())
print(part2())
