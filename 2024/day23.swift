import Foundation

let filename = "input/day23.txt"

func readFile() -> [(String, String)] {
    let contents = try! String(contentsOfFile: filename, encoding: .utf8)
    return contents.split(separator: "\n").map { line in
        let parts = line.components(separatedBy: "-")
        return (parts[0], parts[1])
    }
}

func connectionMap(_ pairs: [(String, String)]) -> [String: Set<String>] {
    var connections = [String: Set<String>]()

    for pair in pairs {
        connections[pair.0, default: Set()].insert(pair.1)
        connections[pair.1, default: Set()].insert(pair.0)
    }

    return connections
}

func part1() -> Int {
    let connections = connectionMap(readFile())
    var count = 0

    var computers = connections.keys.sorted {
        if $0.starts(with: "t") && !$1.starts(with: "t") {
            return true
        }

        if !$0.starts(with: "t") && $1.starts(with: "t") {
            return false
        }

        return $0 < $1
    }

    while !computers.isEmpty {
        let first = computers.removeFirst()

        if !first.starts(with: "t") {
            break
        }

        var firstConnected = connections[first]!.filter(computers.contains)

        while !firstConnected.isEmpty {
            let second = firstConnected.removeFirst()
            count += connections[second]!.filter(firstConnected.contains).count
        }
    }

    return count
}

func part2() -> String {
    let connections = connectionMap(readFile())
    var parties = Set<Set<String>>()

    for computer in connections.keys {
        let connected = connections[computer]!

        for party in parties {
            if party.allSatisfy(connected.contains) {
                var newParty = Set<String>(party)
                newParty.insert(computer)
                parties.insert(newParty)
            }
        }

        parties.insert(Set([computer]))
    }

    return parties.sorted { $0.count > $1.count }.first!.sorted().joined(separator: ",")
}

print(part1())
print(part2())
