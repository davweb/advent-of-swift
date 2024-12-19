import Foundation

let filename = "input/day16.txt"

struct Location: Hashable {
    let x: Int
    let y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    func next(_ direction: Direction) -> Location {
        switch direction {
            case .north: Location(self.x, self.y - 1)
            case .east: Location(self.x + 1, self.y)
            case .south: Location(self.x, self.y + 1)
            case .west: Location(self.x - 1, self.y)
        }
    }
}

enum Direction {
    case north
    case east
    case south
    case west

    func turnLeft() -> Direction {
        switch self {
            case .north: return .west
            case .east: return .north
            case .south: return .east
            case .west: return .south
        }
    }

    func turnRight() -> Direction {
        switch self {
            case .north: return .east
            case .east: return .south
            case .south: return .west
            case .west: return .north
        }
    }
}

struct Step: Hashable {
    let direction: Direction
    let location: Location

    func straight() -> Step {
        Step(direction: self.direction, location: self.location.next(self.direction))
    }

    func turnLeft() -> Step {
        Step(direction: self.direction.turnLeft(), location: self.location)
    }

    func turnRight() -> Step {
        Step(direction: self.direction.turnRight(), location: self.location)
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

func solve(grid: Set<Location>, start: Step, end: Location) -> [Step: Int] {
    var visited = [Step: Int]()
    var queue = [(start, 0)]

    while !queue.isEmpty {
        let (step, score) = queue.removeFirst()

        if grid.contains(step.location) {
            continue
        }

        if visited[step] != nil && visited[step]! <= score {
            continue
        }

        visited[step] = score

        if step.location == end {
            continue
        }

        queue.append((step.turnLeft(), score + 1000))
        queue.append((step.turnRight(), score + 1000))
        queue.append((step.straight(), score + 1))
    }

    return visited
}

func best(visited: [Step: Int], location: Location) -> Int {
    return visited.filter { (key: Step, value: Int) in
        key.location == location
    }.map { (key: Step, value: Int) in
        value
    }.min()!
}

func part1() -> Int {
    let (grid, start, end) = readFile()
    let firstStep = Step(direction: Direction.east, location: start)
    let visited = solve(grid: grid, start: firstStep, end: end)
    return best(visited: visited, location: end)
}

func part2() -> Int {
    let (grid, start, end) = readFile()
    let firstStep = Step(direction: Direction.east, location: start)
    let visited = solve(grid: grid, start: firstStep, end: end)
    let endScore = best(visited: visited, location: end)
    var seats = Set<Location>()

    for (step, score) in visited {
        if seats.contains(step.location) {
            continue
        }

        let tileVisited = solve(grid: grid, start: step, end: end)
        let bestToTile = best(visited: tileVisited, location: end)

        if (bestToTile + score == endScore) {
            seats.insert(step.location)
        }
    }

    return seats.count
}

print(part1())
print(part2())
