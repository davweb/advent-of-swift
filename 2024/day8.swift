import Foundation

let filename = "input/day8.txt"

struct Location: Hashable {
    let x: Int
    let y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

struct Antenna {
    let location: Location
    let frequency: Character
}

func readFile() -> (antennas: [Antenna], xRange: Range<Int>, yRange: Range<Int>) {
    let contents = try! String(contentsOfFile: filename, encoding: .utf8)
    let lines = contents.split(separator: "\n")

    let antennas = lines.enumerated().flatMap { y, line in
        line.enumerated().map { x, char in
            Antenna(location: Location(x, y), frequency: char)
        }
    }.filter {
        $0.frequency != "."
    }

    return (antennas: antennas, xRange: 0 ..< lines[0].count, yRange: 0 ..< lines.count)
}

func pairs<T>(_ list: [T]) -> [(T, T)] {
    var pairs = [(T, T)]()

    for i in 0 ..< list.count - 1 {
        for j in i + 1 ..< list.count {
            pairs.append((list[i], list[j]))
            pairs.append((list[j], list[i]))
        }
    }

    return pairs
}

func locationPairs(_ antennas: [Antenna]) -> [(Location, Location)] {
    let frequencies = Set(antennas.map(\.frequency))

    return frequencies.map { frequency in
        antennas.filter { $0.frequency == frequency }.map(\.location)
    }.flatMap(pairs)
}

func part1() -> Int {
    let input = readFile()

    let antiNodes = locationPairs(input.antennas).map { a, b in
        Location(2 * b.x - a.x, 2 * b.y - a.y)
    }.filter {
        input.xRange.contains($0.x) && input.yRange.contains($0.y)
    }

    return Set(antiNodes).count
}

func part2() -> Int {
    let input = readFile()

    let antiNodes = locationPairs(input.antennas).flatMap { a, b in
        var locations = [Location]()
        let dx = b.x - a.x
        let dy = b.y - a.y
        var x = b.x
        var y = b.y

        while input.xRange.contains(x), input.yRange.contains(y) {
            locations.append(Location(x, y))
            x += dx
            y += dy
        }

        return locations
    }

    return Set(antiNodes).count
}

print(part1())
print(part2())
