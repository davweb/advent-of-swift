import Foundation
import RegexBuilder

let filename = "input/day20.txt"

struct Location: Hashable {
    let x: Int
    let y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    func neighbours() -> [Location] {
        [Location(x - 1, y), Location(x + 1, y), Location(x, y - 1), Location(x, y + 1)]
    }
}

func readFile() -> (grid: Set<Location>, start: Location, end: Location) {
    let contents = try! String(contentsOfFile: filename, encoding: .utf8)
    let lines = contents.split(separator: "\n")
    var grid = Set<Location>()
    var start = Location?.none
    var end = Location?.none

    for (y, line) in lines.enumerated() {
        for (x, char) in line.enumerated() {
            switch char {
            case "#":
                grid.insert(Location(x, y))
            case "S":
                start = Location(x, y)
            case "E":
                end = Location(x, y)
            default:
                break
            }
        }
    }

    return (grid: grid, start: start!, end: end!)
}

func shortestPath(grid: Set<Location>, start: Location, end _: Location) -> [Location: Int] {
    var current: Location? = start
    var distances = [current!: 0]
    var visited = Set<Location>()

    while current != nil {
        let distance = distances[current!]! + 1

        current!.neighbours().filter {
            !visited.contains($0) && !grid.contains($0) && (distances[$0] == nil || distances[$0]! > distance)
        }.forEach {
            distances[$0] = distance
        }

        visited.insert(current!)

        current = distances.filter {
            !visited.contains($0.key)
        }.sorted {
            $0.value < $1.value
        }.first?.key
    }

    return distances
}

func solve(_ cheats: (Location) -> [(end: Location, length: Int)]) -> Int {
    let input = readFile()
    let distances = shortestPath(grid: input.grid, start: input.start, end: input.end)

    return distances.keys.flatMap { start in
        cheats(start).filter { distances[$0.end] != nil }.map { distances[$0.end]! - distances[start]! - $0.length }
    }.filter {
        $0 >= 100
    }.count
}

func part1() -> Int {
    solve { start in [
        (end: Location(start.x, start.y - 2), length: 2),
        (end: Location(start.x, start.y + 2), length: 2),
        (end: Location(start.x - 2, start.y), length: 2),
        (end: Location(start.x + 2, start.y), length: 2),
    ] }
}

func part2() -> Int {
    solve { start in
        (-20 ... 20).flatMap { x in
            (-20 ... 20).map { y in
                (end: Location(start.x + x, start.y + y), length: abs(x) + abs(y))
            }
        }.filter {
            2 ... 20 ~= $0.length
        }
    }
}

print(part1())
print(part2())
