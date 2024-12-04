import Foundation

let filename = "input/day4.txt"

func readFile() -> [[Character]] {
    let contents = try! String(contentsOfFile: filename)
    return contents.split(separator: "\n").map { Array($0) }
}

func lineVariations(_ x: Int, _ y: Int) -> [[(Int, Int)]] {
    (-1 ... 1).flatMap { dx in
        (-1 ... 1).filter { $0 != 0 || dx != 0 }.map { dy in
            (1 ... 3).map { (x + dx * $0, y + dy * $0) }
        }
    }
}

func crossVariations(_ x: Int, _ y: Int) -> [[(Int, Int)]] {
    [
        [(x - 1, y - 1), (x + 1, y + 1), (x - 1, y + 1), (x + 1, y - 1)],
        [(x - 1, y - 1), (x + 1, y + 1), (x + 1, y - 1), (x - 1, y + 1)],
        [(x + 1, y - 1), (x - 1, y + 1), (x + 1, y + 1), (x - 1, y - 1)],
        [(x - 1, y + 1), (x + 1, y - 1), (x + 1, y + 1), (x - 1, y - 1)],
    ]
}

func search(haystack: [[Character]], needle: [Character], variations: (Int, Int) -> [[(Int, Int)]]) -> Int {
    let xRange = 0 ..< haystack.count
    let yRange = 0 ..< haystack.first!.count

    let startingLocations = haystack.indices.flatMap { x in
        haystack.first!.indices.map { y in (x, y) }
    }.filter { x, y in
        haystack[x][y] == needle[0]
    }

    return startingLocations.flatMap { x, y in
        variations(x, y)
    }.filter {
        $0.allSatisfy { x, y in
            xRange.contains(x) && yRange.contains(y)
        }
    }.filter {
        $0.enumerated().allSatisfy { index, location in
            haystack[location.0][location.1] == needle[index + 1]
        }
    }.count
}

func part1() -> Int {
    search(haystack: readFile(), needle: Array("XMAS"), variations: lineVariations)
}

func part2() -> Int {
    search(haystack: readFile(), needle: ["A", "M", "S", "M", "S"], variations: crossVariations)
}

print(part1())
print(part2())