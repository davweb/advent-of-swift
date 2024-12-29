import Foundation

let filename = "input/day6.txt"

enum Direction {
    case north
    case east
    case south
    case west
}

struct Location: Hashable {
    let x: Int
    let y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    func next(_ direction: Direction) -> Location {
        switch direction {
        case .north:
            Location(x, y - 1)
        case .east:
            Location(x + 1, y)
        case .south:
            Location(x, y + 1)
        case .west:
            Location(x - 1, y)
        }
    }
}

struct Step: Hashable {
    let location: Location
    let direction: Direction
}

func readFile() -> (map: [Location: Bool], start: Location) {
    let contents = try! String(contentsOfFile: filename, encoding: .utf8)
    let lines = contents.split(separator: "\n")

    var map = [Location: Bool]()
    var start = Location?.none

    for (y, line) in lines.enumerated() {
        for (x, char) in line.enumerated() {
            let location = Location(x, y)

            switch char {
                case "^":
                    map[location] = false
                    start = location
                case "#":
                    map[location] = true
                default:
                    map[location] = false
            }
        }
    }

    return (map: map, start: start!)
}

func walkMap(map: [Location: Bool], start: Location) -> Set<Step>? {
    var location = start
    var direction = Direction.north
    var path = Set<Step>()

    while map[location] != nil {
        let step = Step(location: location, direction: direction)

        if path.contains(step) {
            return nil
        }

        path.insert(step)
        let next = location.next(direction)

        if map[next] == true {
            direction = switch direction {
            case .north:
                .east
            case .east:
                .south
            case .south:
                .west
            case .west:
                .north
            }
        } else {
            location = next
        }
    }

    return path
}

func part1() -> Int {
    let input = readFile()
    let path = walkMap(map: input.map, start: input.start)!
    return Set(path.map(\.location)).count
}

func part2() -> Int {
    let input = readFile()
    let path = walkMap(map: input.map, start: input.start)!
    let originalLocations = Set(path.map(\.location))

    return originalLocations.filter {
        var map = input.map
        map[$0] = true
        return walkMap(map: map, start: input.start) == nil
    }.count
}

print(part1())
print(part2())
