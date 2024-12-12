import Foundation

let filename = "input/day12.txt"

struct Location: Hashable {
    let x: Int
    let y: Int
}

func readFile() -> [Location: Character] {
    let contents = try! String(contentsOfFile: filename)
    let lines = contents.split(separator: "\n")

    return Dictionary(uniqueKeysWithValues: lines.enumerated().flatMap { y, line in
        line.enumerated().map { x, char in
            (Location(x: x, y: y), char)
        }
    })
}

func edgeNeighbours(_ location: Location) -> Set<Location> {
    Set([
        Location(x: location.x - 1, y: location.y),
        Location(x: location.x + 1, y: location.y),
        Location(x: location.x, y: location.y - 1),
        Location(x: location.x, y: location.y + 1),
    ])
}

func cornerNeighbours(_ loc: Location) -> [Location] {
    (-1 ... 1).flatMap { dx in
        (-1 ... 1).filter { $0 != 0 || dx != 0 }.map { dy in
            Location(x: loc.x + dx, y: loc.y + dy)
        }
    }
}

func triple(_ locations: Set<Location>) -> [Location] {
    return locations.flatMap { location in
        (location.x * 3 ... location.x * 3 + 2).flatMap { x in
            (location.y * 3 ... location.y * 3 + 2).map { y in
                Location(x: x, y: y)
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
            queue.append(contentsOf: edgeNeighbours(current).filter { grid[$0] == plant })
        }

        areas.append(area)
    }

    return areas
}

func calculatePerimeter(_ area: Set<Location>) -> Int {
    return area.flatMap(edgeNeighbours).filter { !area.contains($0) }.count
}

func countSides(_ sourceArea: Set<Location>) -> Int {
    //Tripling the area avoids some edge cases
    let area = triple(sourceArea)
    let perimeter = Set(area.flatMap(cornerNeighbours).filter { !area.contains($0) })

    //Number of corners is the same as the number sides
    return perimeter.filter { location in
        let above = Location(x: location.x, y: location.y - 1)
        let below = Location(x: location.x, y: location.y + 1)
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
