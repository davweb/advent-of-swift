import Foundation
import RegexBuilder

let filename = "input/day15.txt"

enum Tile {
    case wall
    case box
    case robot
    case empty
    case boxLeft
    case boxRight
}

enum Direction {
    case up
    case down
    case left
    case right
}

struct Location {
    let x: Int
    let y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

let gridPattern = Regex {
    Capture {
        OneOrMore {
            ChoiceOf {
                "#"
                "."
                "O"
                "@"
            }
        }
    } transform: {
        $0.map {
            switch $0 {
                case "#": Tile.wall
                case ".": Tile.empty
                case "O": Tile.box
                case "@": Tile.robot
                default: fatalError()
            }
        }
    }
    "\n"
}

let directionPattern = Regex {
    Capture {
        ChoiceOf {
            "^"
            "v"
            "<"
            ">"
        }
    } transform: {
        switch $0 {
            case "^": Direction.up
            case "v": Direction.down
            case "<": Direction.left
            case ">": Direction.right
            default: fatalError()
        }
    }
}

func readFile() -> (grid: [[Tile]], directions: [Direction]) {
    let contents = try! String(contentsOfFile: filename, encoding: .utf8)
    let grid = contents.matches(of: gridPattern).map(\.1)
    let directions = contents.matches(of: directionPattern).map(\.1)
    return (grid: grid, directions: directions)
}

@discardableResult
func move(grid: inout [[Tile]], location: Location, direction: Direction, trialRun: Bool = false) -> Location? {
    let (x, y) = (location.x, location.y)

    let next = switch direction {
        case .up: Location(x, y - 1)
        case .down: Location(x, y + 1)
        case .left: Location(x - 1, y)
        case .right: Location(x + 1, y)
    }

    let nextTile = grid[next.y][next.x]

    switch nextTile {
        case .wall:
            return nil
        case .box:
            if move(grid: &grid, location: next, direction: direction) == nil {
                return nil
            }
        case .boxLeft, .boxRight:
            if direction == .left || direction == .right {
                if move(grid: &grid, location: next, direction: direction) == nil {
                    return nil
                }
            } else {
                let (leftTile, rightTile) = switch nextTile {
                    case .boxLeft: (Location(next.x, next.y), Location(next.x + 1, next.y))
                    case .boxRight: (Location(next.x - 1, next.y), Location(next.x, next.y))
                    default: fatalError()
                }

                let canMoveBox = move(grid: &grid, location: leftTile, direction: direction, trialRun: true) != nil &&
                    move(grid: &grid, location: rightTile, direction: direction, trialRun: true) != nil

                if !canMoveBox {
                    return nil
                }

                if !trialRun {
                    move(grid: &grid, location: leftTile, direction: direction)
                    move(grid: &grid, location: rightTile, direction: direction)
                }
            }
        default:
            break
    }

    if !trialRun {
        grid[next.y][next.x] = grid[y][x]
        grid[y][x] = .empty
    }

    return next
}

func findRobot(_ grid: [[Tile]]) -> Location {
    for (y, row) in grid.enumerated() {
        for (x, tile) in row.enumerated() {
            if tile == .robot {
                return Location(x, y)
            }
        }
    }

    fatalError()
}

func calculate(grid input: [[Tile]], directions: [Direction]) -> Int {
    var grid = input
    var robot = findRobot(grid)

    for direction in directions {
        if let next = move(grid: &grid, location: robot, direction: direction) {
            robot = next
        }
    }

    return grid.enumerated().flatMap { y, row in
        row.enumerated().map { x, tile in
            tile == .box || tile == .boxLeft ? y * 100 + x : 0
        }
    }.reduce(0, +)
}

func part1() -> Int {
    let (grid, directions) = readFile()
    return calculate(grid: grid, directions: directions)
}

func part2() -> Int {
    let (grid, directions) = readFile()

    let doubleGrid = grid.map { row in
        row.flatMap {
            switch $0 {
                case .box: [Tile.boxLeft, Tile.boxRight]
                case .robot: [Tile.robot, Tile.empty]
                case .wall: [Tile.wall, Tile.wall]
                case .empty: [Tile.empty, Tile.empty]
                default: fatalError()
            }
        }
    }

    return calculate(grid: doubleGrid, directions: directions)
}

print(part1())
print(part2())
