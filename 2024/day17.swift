
let instructions = [2,4,1,1,7,5,1,5,0,3,4,3,5,5,3,0]
let registerA = 56256477

func pow(_ x: Int) -> Int {
    switch x {
        case 0: 1
        case 1: 2
        case 2: 4
        case 3: 8
        case 4: 16
        case 5: 32
        case 6: 64
        case 7: 128
        default: fatalError()
    }
}

func part1() -> [Int] {
    var a = registerA
    var output = [Int]()

    while a != 0 {
        var b = a % 8 ^ 1
        let c = a / pow(b)
        b = b ^ 5 ^ c % 8
        a = a / 8
        output.append(b)
    }

    return output
}

func part2() -> Int {
    var result = Int.max
    var queue = [(instructions, 0)]

    while !queue.isEmpty {
        var (output, start) = queue.removeFirst()
        let after = output.removeLast()

        for a in start * 8...start * 8 + 7 {
            var b = a % 8 ^ 1
            let c = a / pow(b)
            b = b ^ 5 ^ c % 8

            if (b == after) {
                if output.isEmpty {
                    result = min(result, a)
                }
                else {
                    queue.append((output, a))
                }
            }
        }
    }

    return result
}

print(part1())
print(part2())
