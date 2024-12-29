import Foundation
import RegexBuilder

let filename = "input/day13.txt"

let number = Regex {
    Capture {
        OneOrMore(.digit)
    } transform: {
        Int($0)!
    }
}

let clawPattern = Regex {
    "Button A: X+"
    number
    ", Y+"
    number
    "\nButton B: X+"
    number
    ", Y+"
    number
    "\nPrize: X="
    number
    ", Y="
    number
}

struct Location {
    let x: Int
    let y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

struct ClawGame {
    let buttonA: Location
    let buttonB: Location
    let prize: Location
}

func readFile() -> [ClawGame] {
    let contents = try! String(contentsOfFile: filename, encoding: .utf8)
    return contents.matches(of: clawPattern).map {
        ClawGame(
            buttonA: Location($0.1, $0.2),
            buttonB: Location($0.3, $0.4),
            prize: Location($0.5, $0.6)
        )
    }
}

func binarySearch(lowerBound: Int = 0, upperBound: Int, calc: (Int) -> Int) -> Int {
    var low = lowerBound
    var high = upperBound

    while low < high {
        let mid = (low + high) / 2
        let result = calc(mid)

        if result == 0 {
            return mid
        }

        if result < 0 {
            low = mid + 1
        } else {
            high = mid
        }
    }

    return low
}

func optimisePrice(game: ClawGame) -> Int? {
    var buttonA: Location
    var buttonB: Location
    var costA: Int
    var costB: Int

    // "Steepest" button first
    if game.buttonA.y * game.buttonB.x >= game.buttonA.x * game.buttonB.y {
        buttonA = game.buttonA
        buttonB = game.buttonB
        costA = 3
        costB = 1
    } else {
        buttonA = game.buttonB
        buttonB = game.buttonA
        costA = 1
        costB = 3
    }

    let bestX = binarySearch(upperBound: game.prize.x) { x in
        // This matches the paths to the prize but multiplied by buttonA.x * buttonB.x to avoid division problems
        (x * buttonA.y * buttonB.x + (game.prize.x - x) * buttonB.y * buttonA.x) - game.prize.y * buttonA.x * buttonB.x
    }

    let aTurns = bestX / buttonA.x
    let bTurns = (game.prize.x - bestX) / buttonB.x

    // bestX could be outside valid moves
    if aTurns * buttonA.y + bTurns * buttonB.y != game.prize.y {
        return nil
    }

    return aTurns * costA + bTurns * costB
}

func part1() -> Int {
    let games = readFile()
    return games.compactMap(optimisePrice).reduce(0,+)
}

func part2() -> Int {
    let games = readFile().map {
        ClawGame(
            buttonA: $0.buttonA,
            buttonB: $0.buttonB,
            prize: Location($0.prize.x + 10_000_000_000_000, $0.prize.y + 10_000_000_000_000)
        )
    }

    return games.compactMap(optimisePrice).reduce(0,+)
}

print(part1())
print(part2())
