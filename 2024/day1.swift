import Foundation

let filename = "input/day1.txt"

func readFile() -> (a: [Int], b: [Int]) {
    let contents = try! String(contentsOfFile: filename, encoding: .utf8)

    return contents.split(separator: "\n").map { $0.split(separator: " ") }.reduce(into: (a: [Int](), b: [Int]())) {
        $0.a.append(Int($1[0])!)
        $0.b.append(Int($1[1])!)
    }
}

func part1() -> Int {
    var locations = readFile()
    locations.a.sort()
    locations.b.sort()

    return zip(locations.a, locations.b).map { abs($0.0 - $0.1) }.reduce(0, +)
}

func part2() -> Int {
    let locations = readFile()

    return locations.a.map { a in
        a * locations.b.filter { $0 == a }.count
    }.reduce(0, +)
}

print(part1())
print(part2())
