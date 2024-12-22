import Foundation
import RegexBuilder

let filename = "input/day21.txt"

func readFile() -> [String] {
    let contents = try! String(contentsOfFile: filename, encoding: .utf8)
    return contents.split(separator: "\n").map { String($0) }
}

let numberPattern = Regex {
    Capture {
        OneOrMore(.digit)
    } transform: {
        Int($0)!
    }
}

// Which keys are adjacent to each other on a keypad
let numericKeypadKeyMap: [Character: [Character: Character]] = [
    "7": [">": "8", "v": "4"],
    "8": ["<": "7", ">": "9", "v": "5"],
    "9": ["<": "8", "v": "6"],
    "4": ["^": "7", ">": "5", "v": "1"],
    "5": ["^": "8", "<": "4", ">": "6", "v": "2"],
    "6": ["^": "9", "<": "5", "v": "3"],
    "1": ["^": "4", ">": "2"],
    "2": ["^": "5", "<": "1", ">": "3", "v": "0"],
    "3": ["^": "6", "<": "2", "v": "A"],
    "0": ["^": "2", ">": "A"],
    "A": ["^": "3", "<": "0"],
]

let robotKeypadKeyMap: [Character: [Character: Character]] = [
    "^": ["v": "v", ">": "A"],
    "A": ["<": "^", "v": ">"],
    "<": [">": "v"],
    "v": ["^": "^", ">": ">", "<": "<"],
    ">": ["<": "v", "^": "A"],
]

// Calculate the shortest route between two keys on a keypad based on the cost of an upstream keypad
func shortestRoute(keyMap: [Character: [Character: Character]], upstreamKeypad: (Character, Character) -> Int, start: Character, end: Character) -> Int {
    struct Path {
        let visited: [Character]
        let directions: [Character]
    }

    var queue = [Path(visited: [start], directions: [])]
    var paths = [Path]()

    while !queue.isEmpty {
        let path = queue.removeFirst()
        let current = path.visited.last!

        if current == end {
            paths.append(path)
            continue
        }

        for (direction, button) in keyMap[current]! {
            if path.visited.contains(button) {
                continue
            }

            let nextPath = Path(visited: path.visited + [button], directions: path.directions + [direction])
            queue.append(nextPath)
        }
    }

    var routes = [Int]()

    for path in paths {
        let route = path.directions + ["A"]
        var buttonPresses = 0
        var previousButton: Character = "A"

        for button in route {
            buttonPresses += upstreamKeypad(previousButton, button)
            previousButton = button
        }

        routes.append(buttonPresses)
    }

    return routes.sorted().first!
}

// Return a function that returns the number of keypresses between two keys for a given keypad
func shortestPaths(keyMap: [Character: [Character: Character]], upstreamKeypad: (Character, Character) -> Int) -> (Character, Character) -> Int {
    let keys = keyMap.keys
    var distances = [String: Int]()

    for from in keys {
        for to in keys {
            distances["\(from)\(to)"] = shortestRoute(keyMap: keyMap, upstreamKeypad: upstreamKeypad, start: from, end: to)
        }
    }

    return { from, to in
        distances["\(from)\(to)"]!
    }
}

// Calculate the number of keypresses between two keys for a given keypad
func countKeyPresses(code: String, keyPad: (Character, Character) -> Int) -> Int {
    var previous: Character = "A"
    var output = 0

    for character in code {
        output += keyPad(previous, character)
        previous = character
    }

    return output
}

// At the bottom level the keys are just a single keypress
func myKeyPad(previous _: Character, next _: Character) -> Int {
    1
}

func solve(_ penultimateKeypad: (Character, Character) -> Int) -> Int {
    let numberPad = shortestPaths(keyMap: numericKeypadKeyMap, upstreamKeypad: penultimateKeypad)

    return readFile().map { code in
        let keyPresses = countKeyPresses(code: code, keyPad: numberPad)
        let numericCode = code.firstMatch(of: numberPattern)!.1
        return keyPresses * numericCode
    }.reduce(0, +)
}

func part1() -> Int {
    let robotKeypadOne = shortestPaths(keyMap: robotKeypadKeyMap, upstreamKeypad: myKeyPad)
    let robotKeypadTwo = shortestPaths(keyMap: robotKeypadKeyMap, upstreamKeypad: robotKeypadOne)
    return solve(robotKeypadTwo)
}

func part2() -> Int {
    var previousKeypad = myKeyPad
    var nextKeypad: (Character, Character) -> Int = myKeyPad

    for _ in 1 ... 25 {
        nextKeypad = shortestPaths(keyMap: robotKeypadKeyMap, upstreamKeypad: previousKeypad)
        previousKeypad = nextKeypad
    }

    return solve(nextKeypad)
}

print(part1())
print(part2())
