import Foundation

let filename = "input/day22.txt"

func readFile() -> [Int] {
    let contents = try! String(contentsOfFile: filename, encoding: .utf8)
    return contents.components(separatedBy: .newlines).map { Int($0)! }
}

func next(_ secret: Int) -> Int {
    var output = ((secret * 64) ^ secret) % 16_777_216
    output = ((output / 32) ^ output) % 16_777_216
    return ((output * 2048) ^ output) % 16_777_216
}

func secrets(_ input: Int) -> [Int] {
    (1 ... 2000).reduce([input]) { output, _ in
        output + [next(output.last!)]
    }
}

func monkeyPrices(_ secrets: [Int]) -> [[Int]: Int] {
    var bestPrices = [[Int]: Int]()
    var changes = [Int]()
    var previousPrice = secrets[0] % 10

    for secret in secrets[1...] {
        let price = secret % 10
        changes = changes.suffix(3) + [price - previousPrice]
        previousPrice = price

        if changes.count == 4, bestPrices[changes] == nil {
            bestPrices[changes] = price
        }
    }

    return bestPrices
}

func part1() -> Int {
    let monkeys = readFile()
    return monkeys.map { secrets($0).last! }.reduce(0, +)
}

func part2() -> Int {
    let monkeys = readFile()
    var bestPrices = [[Int]: Int]()

    for monkey in monkeys {
        let secrets = secrets(monkey)

        for (changes, bananas) in monkeyPrices(secrets) {
            bestPrices[changes] = (bestPrices[changes] ?? 0) + bananas
        }
    }

    return bestPrices.values.max()!
}

print(part1())
print(part2())
