import Foundation

let filename = "input/day10.txt"

struct Location: Hashable {
    let x: Int
    let y: Int
}

func readFile() -> [Location: Int] {
    let contents = try! String(contentsOfFile: filename)
    let lines = contents.split(separator: "\n")

    return Dictionary(uniqueKeysWithValues: lines.enumerated().flatMap { y, line in
        line.enumerated().map { x, char in
            (Location(x: x, y: y), Int(String(char))!)
        }
    })
}

func neighbours(location: Location) -> [Location] {
    [
        Location(x: location.x - 1, y: location.y),
        Location(x: location.x + 1, y: location.y),
        Location(x: location.x, y: location.y - 1),
        Location(x: location.x, y: location.y + 1),
    ]
}

func walkRoutes(grid: [Location: Int], location: Location, target: Int = 1) -> Int {
    let next = neighbours(location: location).filter { grid[$0] == target }

    if target == 9 {
        return next.count
    } else {
        return next.map {
            walkRoutes(grid: grid, location: $0, target: target + 1)
        }.reduce(0, +)
    }
}

func walkDestinations(grid: [Location: Int], location: Location, target: Int = 1) -> Set<Location> {
    let next = neighbours(location: location).filter { grid[$0] == target }

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
    let start = grid.filter { $0.1 == 0 }.map(\.0)

    return start.map {
        walkRoutes(grid: grid, location: $0)
    }.reduce(0, +)
}

print(part1())
print(part2())
