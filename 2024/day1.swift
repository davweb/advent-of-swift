import Foundation

let filename = "input/day1.txt"

struct Locations {
    var a: [Int] = []
    var b: [Int] = []
}

func readFile() -> Locations {
    let contents = try! String(contentsOfFile: filename)
    var locations = Locations()

    contents.split(separator: "\n").map { $0.split(separator: " ") }.forEach {
        locations.a.append(Int($0[0])!)
        locations.b.append(Int($0[1])!)
    }

    return locations
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
