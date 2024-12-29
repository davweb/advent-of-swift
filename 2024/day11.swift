import Foundation

let filename = "input/day11.txt"

func readFile() -> [Int] {
    let contents = try! String(contentsOfFile: filename, encoding: .utf8)
    return contents.split(separator: " ").map { Int($0)! }
}

struct Turn: Hashable {
    let stone: Int
    let blinks: Int
}

var cache = [Turn: Int]()

func calculate(_ stone: Int, blinks: Int = 25) -> Int {
    if blinks == 0 {
        return 1
    }

    let turn = Turn(stone: stone, blinks: blinks)

    if let stoneCount = cache[turn] {
        return stoneCount
    }

    let stoneCount = blink(stone).compactMap { calculate($0, blinks: blinks - 1) }.reduce(0, +)
    cache[turn] = stoneCount
    return stoneCount
}

func blink(_ stone: Int) -> [Int] {
    if stone == 0 {
        return [1]
    }

    let text = String(stone)

    if text.count % 2 == 0 {
        let left = text.prefix(text.count / 2)
        let right = text.suffix(text.count / 2)
        return [Int(left)!, Int(right)!]
    }

    return [stone * 2024]
}

func part1() -> Int {
    readFile().map { calculate($0) }.reduce(0, +)
}

func part2() -> Int {
    readFile().map { calculate($0, blinks: 75) }.reduce(0, +)
}

print(part1())
print(part2())
