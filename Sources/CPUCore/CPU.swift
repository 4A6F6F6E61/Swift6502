enum CPUError: Error {
    case unknownOpcode(Byte)
    case unhandledInstruction(Instruction)
    case unhandledAddressingMode(AddressingMode)
}

public struct CPU {
    var pc: Word // Program Counter

    // should be Byte, change later
    var sp: Word // Stack Pointer

    // Registers
    public var a: Byte, x: Byte, y: Byte

    var flags: Byte // Status Flags

    var c: Bool {
        get { (flags & 0b00000001) != 0 }
        set { flags = newValue ? (flags | 0b00000001) : (flags & ~0b00000001) }
    }

    var z: Bool {
        get { (flags & 0b00000010) != 0 }
        set { flags = newValue ? (flags | 0b00000010) : (flags & ~0b00000010) }
    }

    var i: Bool {
        get { (flags & 0b00000100) != 0 }
        set { flags = newValue ? (flags | 0b00000100) : (flags & ~0b00000100) }
    }

    var d: Bool {
        get { (flags & 0b00001000) != 0 }
        set { flags = newValue ? (flags | 0b00001000) : (flags & ~0b00001000) }
    }

    var b: Bool {
        get { (flags & 0b00010000) != 0 }
        set { flags = newValue ? (flags | 0b00010000) : (flags & ~0b00010000) }
    }

    var v: Bool {
        get { (flags & 0b00100000) != 0 }
        set { flags = newValue ? (flags | 0b00100000) : (flags & ~0b00100000) }
    }

    var n: Bool {
        get { (flags & 0b01000000) != 0 }
        set { flags = newValue ? (flags | 0b01000000) : (flags & ~0b01000000) }
    }

    public var memory: Memory

    public init() {
        pc = 0xFFFC
        sp = 0x0100
        flags = 0x00
        a = 0x00
        x = 0x00
        y = 0x00
        memory = Memory()
    }

    public mutating func reset() {
        pc = 0xFFFC
        sp = 0x0100
        flags = 0x00
        a = 0x00
        x = 0x00
        y = 0x00
        memory = Memory()
    }

    mutating func fetchByte(_ cycles: inout UInt32) -> Byte
    {
        let data = memory[pc]
        pc &+= 1
        cycles &-= 1
        return data
    }

    mutating func fetchWord(_ cycles: inout UInt32) -> Word
    {
        let lo = fetchByte(&cycles)
        let hi = fetchByte(&cycles)
        return Word(hi) << 8 | Word(lo)
    }

    mutating func readWord(_ addr: Word, _ cycles: inout UInt32) -> Word
    {
        let lo = readByte(addr, &cycles)
        let hi = readByte(addr &+ 1, &cycles)
        return Word(hi) << 8 | Word(lo)
    }

    mutating func readWord(_ addr: Byte, _ cycles: inout UInt32) -> Word
    {
        return readWord(Word(addr), &cycles)
    }

    mutating func readByte(_ addr: Byte, _ cycles: inout UInt32) -> Byte
    {
        return readByte(Word(addr), &cycles)
    }

    mutating func readByte(_ addr: Word, _ cycles: inout UInt32) -> Byte
    {
        let data = memory[addr]
        cycles &-= 1
        return data
    }

    public mutating func execute(_ cycles: UInt32) throws
    {
        print("\n\n\n\n\n\n\n\n\nExecuting \(cycles) cycles")

        var cycles = cycles
        while cycles > 0 {
            let maybe_opcode = fetchByte(&cycles) // -1

            let (instruction, mode) = decodeOpcode(maybe_opcode)

            guard let instruction = instruction, let mode = mode else {
                throw CPUError.unknownOpcode(maybe_opcode)
            }
            switch instruction {
            case .lda: // LDA Immediate
                try lda(&cycles, mode)
                break
            case .jsr: // JSR Absolute
                jsr(&cycles, mode)
                break
            default:
                throw CPUError.unhandledInstruction(instruction)
            }
        }
    }

    mutating func lda(_ cycles: inout UInt32, _ mode: AddressingMode) throws
    {
        switch mode {
        case .imm:
            a = fetchByte(&cycles)
            break
        case .zp:
            let zeroPageAddr = fetchByte(&cycles)
            a = readByte(zeroPageAddr, &cycles)
            break
        case .zpx:
            let zeroPageAddr = fetchByte(&cycles)
            cycles &-= 1
            a = readByte(zeroPageAddr + x, &cycles)
            break
        case .abs:
            let addr = fetchWord(&cycles)
            a = readByte(addr, &cycles)
        break
        case .abx:
            let addr = fetchWord(&cycles)
            a = readByte(addr + x, &cycles)
        break
        case .aby:
            let addr = fetchWord(&cycles)
            a = readByte(addr + y, &cycles)
        break
        case .idx:
            let zeroPageAddr = fetchByte(&cycles)
            cycles &-= 1
            let addr = readWord(zeroPageAddr &+ x, &cycles)
            a = readByte(addr, &cycles)
        break
        case .idy:
            let zeroPageAddr = fetchByte(&cycles)
            let addr = readWord(zeroPageAddr, &cycles)
            let addrY = addr + Word(y)
            let crossedPageBoundary = (addr ^ addrY) >> 8 != 0
            if (crossedPageBoundary) {
                cycles &-= 1
            }
            a = readByte(addrY, &cycles)
        break
        default:
            throw CPUError.unhandledAddressingMode(mode)
        }
        lda_set_status()
    }

    mutating func lda_set_status()
    {
        z = a == 0
        n = (a & 0b10000000) != 0
    }

    mutating func jsr(_ cycles: inout UInt32, _ mode: AddressingMode)
    {
        switch mode {
        case .abs:
            let addr = fetchWord(&cycles)
            memory[sp &- 1] = Byte(pc >> 8)
            memory[sp &- 2] = Byte(pc & 0xFF)
            sp &-= 2
            pc = addr
            cycles &-= 6
            break
        default:
            print("Unhandled addressing mode: \(mode)")
            break
        }
    }

    public func toString() -> String
    {
        return """
        CPU {
            PC: \(toHex(pc))
            SP: \(toHex(sp))
            A: \(toHex(a))
            X: \(toHex(x))
            Y: \(toHex(y))
            Flags(\(toHex(flags))) {
                C: \(c)
                Z: \(z)
                I: \(i)
                D: \(d)
                B: \(b)
                V: \(v)
                N: \(n)
            }
        }
        """
    }
}