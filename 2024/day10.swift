import Foundation

let filename = "input/day10.txt"

struct Location: Hashable {
    let x: Int
    let y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    func neighbours() -> [Location] {
        [
            Location(x - 1, y),
            Location(x + 1, y),
            Location(x, y - 1),
            Location(x, y + 1),
        ]
    }
}

func readFile() -> [Location: Int] {
    let contents = try! String(contentsOfFile: filename, encoding: .utf8)
    let lines = contents.split(separator: "\n")

    return Dictionary(uniqueKeysWithValues: lines.enumerated().flatMap { y, line in
        line.enumerated().map { x, char in
            (Location(x, y), Int(String(char))!)
        }
    })
}

func walkRoutes(grid: [Location: Int], locations: [Location], target: Int = 0) -> Int {
    let next = locations.filter { grid[$0] == target }

    if target == 9 {
        return next.count
    } else {
        return next.map {
            walkRoutes(grid: grid, locations: $0.neighbours(), target: target + 1)
        }.reduce(0, +)
    }
}

func walkDestinations(grid: [Location: Int], location: Location, target: Int = 1) -> Set<Location> {
    let next = location.neighbours().filter { grid[$0] == target }

    if target == 9 {
        return Set(next)
    } else {
        return next.map {
            walkDestinations(grid: grid, location: $0, target: target + 1)
        }.reduce(Set<Location>()) {
            $0.union($1)
        }
    }
}

func part1() -> Int {
    let grid = readFile()
    let start = grid.filter { $0.1 == 0 }.map(\.0)

    return start.map {
        walkDestinations(grid: grid, location: $0).count
    }.reduce(0, +)
}

func part2() -> Int {
    let grid = readFile()
    return walkRoutes(grid: grid, locations: Array(grid.keys))
}

print(part1())
print(part2())
