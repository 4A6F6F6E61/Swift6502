public struct CPU {
    private var pc: Word // Program Counter

    // should be Byte, change later
    private var sp: Word // Stack Pointer

    // Registers
    private var a: Byte, x: Byte, y: Byte

    private var flags: Byte // Status Flags

    private var c: Bool {
        get { (flags & 0b00000001) != 0 }
        set { flags = newValue ? (flags | 0b00000001) : (flags & ~0b00000001) }
    }

    private var z: Bool {
        get { (flags & 0b00000010) != 0 }
        set { flags = newValue ? (flags | 0b00000010) : (flags & ~0b00000010) }
    }

    private var i: Bool {
        get { (flags & 0b00000100) != 0 }
        set { flags = newValue ? (flags | 0b00000100) : (flags & ~0b00000100) }
    }

    private var d: Bool {
        get { (flags & 0b00001000) != 0 }
        set { flags = newValue ? (flags | 0b00001000) : (flags & ~0b00001000) }
    }

    private var b: Bool {
        get { (flags & 0b00010000) != 0 }
        set { flags = newValue ? (flags | 0b00010000) : (flags & ~0b00010000) }
    }

    private var v: Bool {
        get { (flags & 0b00100000) != 0 }
        set { flags = newValue ? (flags | 0b00100000) : (flags & ~0b00100000) }
    }

    private var n: Bool {
        get { (flags & 0b01000000) != 0 }
        set { flags = newValue ? (flags | 0b01000000) : (flags & ~0b01000000) }
    }

    var memory: Memory

    init() {
        pc = 0xFFFC
        sp = 0x0100
        flags = 0x00
        a = 0x00
        x = 0x00
        y = 0x00
        memory = Memory()
    }

    mutating func reset() {
        pc = 0xFFFC
        sp = 0x0100
        flags = 0x00
        a = 0x00
        x = 0x00
        y = 0x00
        memory = Memory()
    }

    mutating func fetchByte(_ cycles: inout UInt32) -> Byte {
        let data = memory[pc]
        pc &+= 1
        cycles &-= 1
        return data
    }

    mutating func fetchWord(_ cycles: inout UInt32) -> Word {
        let lo = fetchByte(&cycles)
        let hi = fetchByte(&cycles)
        return Word(hi) << 8 | Word(lo)
    }

    mutating func readByte(_ addr: Byte, _ cycles: inout UInt32) -> Byte {
        let data = memory[addr]
        cycles &-= 1
        return data
    }

    mutating func execute(_ cycles: UInt32) {
        var cycles = cycles
        while cycles > 0 {
            let maybe_opcode = fetchByte(&cycles)

            let (instruction, mode) = decodeOpcode(maybe_opcode)

            guard let instruction = instruction, let mode = mode else {
                print("Unknown opcode: \(maybe_opcode)")
                continue
            }
            switch instruction {
            case .lda: // LDA Immediate
                lda(&cycles, mode)
                break
            case .jsr: // JSR Absolute
                jsr(&cycles, mode)
                break
            default:
                fatalError("Unhandled instruction: \(instruction)")
            }
        }
    }

    mutating func lda(_ cycles: inout UInt32, _ mode: AddressingMode) {
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
            a = readByte(zeroPageAddr + x, &cycles)
            break
        default:
            fatalError("Unhandled addressing mode: \(mode)")
        }
        lda_set_status()
    }

    mutating func lda_set_status() {
        z = a == 0
        n = (a & 0b10000000) != 0
    }

    mutating func jsr(_ cycles: inout UInt32, _ mode: AddressingMode) {
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

    func toString() -> String {
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