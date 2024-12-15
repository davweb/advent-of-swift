import Foundation
import RegexBuilder

let filename = "input/day14.txt"

let width = 101
let height = 103

let number = Regex {
    Capture {
        Optionally("-")
        OneOrMore(.digit)
    } transform: {
        Int($0)!
    }
}

let robotPattern = Regex {
    "p="
    number
    ","
    number
    " v="
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

struct Robot {
    let position: Location
    let velocity: Location
}

func readFile() -> [Robot] {
    let contents = try! String(contentsOfFile: filename)
    return contents.matches(of: robotPattern).map {
        Robot(
            position: Location($0.1, $0.2),
            velocity: Location($0.3, $0.4)
        )
    }
}

func move(_ robot: Robot) -> Robot {
    var x = (robot.position.x + robot.velocity.x)
    while x < 0 {
        x += width
    }
    while x >= width {
        x -= width
    }

    var y = (robot.position.y + robot.velocity.y)
    while y < 0 {
        y += height
    }
    while y >= height {
        y -= height
    }

    return Robot(
        position: Location(x, y),
        velocity: robot.velocity
    )
}

func gcd(_ one: Int, _ two: Int) -> Int {
    var a = one
    var b = two

    while b != 0 {
        (a, b) = (b, a % b)
    }

    return a
}

func lcm(a: Int, b: Int) -> Int {
    a * b / gcd(a, b)
}

func lcm(_ numbers: [Int]) -> Int {
    numbers.reduce(1, lcm)
}

func cycleCount(_ robot: Robot) -> Int {
    let initial = robot
    var current = move(robot)
    var turns = 1

    while current.position != initial.position {
        current = move(current)
        turns += 1
    }

    return turns
}

func part1() -> Int {
    var robots = readFile()

    for _ in 1 ... 100 {
        robots = robots.map(move)
    }

    let quadrants = [
        (0 ... 49, 0 ... 50),
        (51 ... 100, 0 ... 50),
        (0 ... 49, 52 ... 102),
        (51 ... 100, 52 ... 102),
    ]

    return quadrants.map { quadrant in
        robots.filter { robot in
            quadrant.0.contains(robot.position.x) && quadrant.1.contains(robot.position.y)
        }.count
    }.reduce(1,*)
}

func part2() -> Int {
    var robots = readFile()
    let cycleTime = lcm(robots.map(cycleCount))

    for seconds in 1 ... cycleTime {
        robots = robots.map(move)

        robots.sort { a, b in
            a.position.y == b.position.y ? a.position.x < b.position.x : a.position.y < b.position.y
        }

        var previous = Location(-1, -1)
        var maxLength = 0
        var length = 0

        for robot in robots {
            if robot.position.y == previous.y, robot.position.x == previous.x + 1 {
                length += 1
                maxLength = max(maxLength, length)
            } else {
                length = 0
            }

            previous = robot.position
        }

        if maxLength >= 10 {
            var grid = Array(repeating: Array(repeating: ".", count: width), count: height)

            for robot in robots {
                grid[robot.position.y][robot.position.x] = "#"
            }

            print(grid.map { $0.joined() }.joined(separator: "\n"))
            return seconds
        }
    }

    fatalError()
}

print(part1())
print(part2())
