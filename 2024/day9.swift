import Foundation

let filename = "input/day9.txt"

func readFile() -> String {
    try! String(contentsOfFile: filename, encoding: .utf8)
}

func part1() -> Int {
    var space = true
    var fileId = 0

    var disk = readFile().flatMap {
        if space {
            space = false
        } else {
            space = true
            fileId += 1
        }

        return Array(repeating: space ? -1 : fileId, count: Int(String($0))!)
    }

    var spaceIndex = disk.firstIndex(of: -1)!
    var dataIndex = disk.endIndex - 1

    while spaceIndex < dataIndex {
        disk[spaceIndex] = disk[dataIndex]
        disk[dataIndex] = -1

        while disk[spaceIndex] != -1 {
            spaceIndex += 1
        }

        while disk[dataIndex] == -1 {
            dataIndex -= 1
        }
    }

    return disk.enumerated().filter { $0.1 != -1 }.map { $0.0 * $0.1 }.reduce(0,+)
}

struct Fragment {
    let length: Int
    let fileId: Int
    let space: Bool
}

func part2() -> Int {
    var space = true
    var fileId = 0

    var disk = readFile().map {
        if space {
            space = false
        } else {
            space = true
            fileId += 1
        }

        return Fragment(length: Int(String($0))!, fileId: space ? 0 : fileId, space: space)
    }

    disk.append(Fragment(length: 0, fileId: 0, space: true))
    var index = disk.endIndex - 1

    while index > 0 {
        index -= 1
        let fragment = disk[index]

        if fragment.space {
            continue
        }

        let spaceIndex = disk.firstIndex { $0.space && $0.length >= fragment.length }

        if spaceIndex == nil || spaceIndex! >= index {
            continue
        }

        let previous = disk[index + 1]

        if previous.space {
            disk.replaceSubrange(index ... index + 1, with: [Fragment(length: previous.length + fragment.length, fileId: 0, space: true)])
        } else {
            disk[index] = Fragment(length: fragment.length, fileId: 0, space: true)
        }

        let spaceRemaining = disk[spaceIndex!].length - fragment.length

        if spaceRemaining > 0 {
            disk.replaceSubrange(spaceIndex! ... spaceIndex!, with: [fragment, Fragment(length: spaceRemaining, fileId: 0, space: true)])
            index += 1
        } else {
            disk[spaceIndex!] = fragment
        }
    }

    return disk.flatMap { Array(repeating: $0.fileId, count: $0.length) }.enumerated().map { $0.0 * $0.1 }.reduce(0,+)
}

print(part1())
print(part2())
