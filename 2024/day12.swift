import Foundation

let filename = "input/day12.txt"

struct Location: Hashable {
    let x: Int
    let y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    func edgeNeighbours() -> Set<Location> {
        Set([
            Location(self.x - 1, self.y),
            Location(self.x + 1, self.y),
            Location(self.x, self.y - 1),
            Location(self.x, self.y + 1),
        ])
    }

    func cornerNeighbours() -> [Location] {
        (-1 ... 1).flatMap { dx in
            (-1 ... 1).filter { $0 != 0 || dx != 0 }.map { dy in
                Location(self.x + dx, self.y + dy)
            }
        }
    }
}

func readFile() -> [Location: Character] {
    let contents = try! String(contentsOfFile: filename, encoding: .utf8)
    let lines = contents.split(separator: "\n")

    return Dictionary(uniqueKeysWithValues: lines.enumerated().flatMap { y, line in
        line.enumerated().map { x, char in
            (Location(x, y), char)
        }
    })
}


func triple(_ locations: Set<Location>) -> [Location] {
    return locations.flatMap { location in
        (location.x * 3 ... location.x * 3 + 2).flatMap { x in
            (location.y * 3 ... location.y * 3 + 2).map { y in
                Location(x, y)
            }
        }
    }
}

func findAreas(grid: [Location: Character]) -> [Set<Location>] {
    var seen = Set<Location>()
    var areas = [Set<Location>]()

    for (location, plant) in grid {
        if seen.contains(location) {
            continue
        }

        var queue = [location]
        var area = Set<Location>()

        while !queue.isEmpty {
            let current = queue.removeFirst()

            if seen.contains(current) {
                continue
            }

            seen.insert(current)
            area.insert(current)
            queue.append(contentsOf: current.edgeNeighbours().filter { grid[$0] == plant })
        }

        areas.append(area)
    }

    return areas
}

func calculatePerimeter(_ area: Set<Location>) -> Int {
    return area.flatMap { $0.edgeNeighbours() }.filter { !area.contains($0) }.count
}

func countSides(_ sourceArea: Set<Location>) -> Int {
    //Tripling the area avoids some edge cases
    let area = triple(sourceArea)
    let perimeter = Set(area.flatMap { $0.cornerNeighbours() }.filter { !area.contains($0) })

    //Number of corners is the same as the number sides
    return perimeter.filter { location in
        let above = Location(location.x, location.y - 1)
        let below = Location(location.x, location.y + 1)
        return perimeter.contains(above) != perimeter.contains(below)
    }.count
}

func part1() -> Int {
    return findAreas(grid: readFile()).map { $0.count * calculatePerimeter($0) }.reduce(0, +)
}

func part2() -> Int {
    return findAreas(grid: readFile()).map { $0.count * countSides($0) }.reduce(0, +)
}

print(part1())
print(part2())
