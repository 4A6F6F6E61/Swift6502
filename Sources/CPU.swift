import Foundation

enum OpCode: Byte {
    case lda_imm = 0xA9
    case lda_zp  = 0xA5
    case lda_zpx = 0xB5
    case jsr_abs = 0x20
}

public struct CPU {
    private var pc: Word // Program Counter

    // should be Byte, change later
    private var sp: Word // Stack Pointer

    // Registers
    private var a: Byte, x: Byte, y: Byte

    private var flags: Byte // Status Flags

    private var c: Bool {
        get { (flags & 0b00000001) != 0 } // Check the first bit
        set { flags = newValue ? (flags | 0b00000001) : (flags & ~0b00000001) }
    }

    private var z: Bool {
        get { (flags & 0b00000010) != 0 } // Check the second bit
        set { flags = newValue ? (flags | 0b00000010) : (flags & ~0b00000010) }
    }

    private var i: Bool {
        get { (flags & 0b00000100) != 0 } // Check the third bit
        set { flags = newValue ? (flags | 0b00000100) : (flags & ~0b00000100) }
    }

    private var d: Bool {
        get { (flags & 0b00001000) != 0 } // Check the fourth bit
        set { flags = newValue ? (flags | 0b00001000) : (flags & ~0b00001000) }
    }

    private var b: Bool {
        get { (flags & 0b00010000) != 0 } // Check the fifth bit
        set { flags = newValue ? (flags | 0b00010000) : (flags & ~0b00010000) }
    }

    private var v: Bool {
        get { (flags & 0b00100000) != 0 } // Check the sixth bit
        set { flags = newValue ? (flags | 0b00100000) : (flags & ~0b00100000) }
    }

    private var n: Bool {
        get { (flags & 0b10000000) != 0 } // Check the seventh bit
        set { flags = newValue ? (flags | 0b10000000) : (flags & ~0b10000000) }
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

            if let opcode = OpCode(rawValue: maybe_opcode) {
                switch opcode {
                case .lda_imm: // LDA Immediate
                    lda_imm(&cycles)
                    break
                case .lda_zp: // LDA Zero Page
                    lda_zp(&cycles)
                    break
                case .lda_zpx: // LDA Zero Page, X
                    lda_zpx(&cycles)
                    break
                case .jsr_abs: // JSR Absolute
                    jsr_abs(&cycles)
                    break
                }
            } else {
                print("Unknown opcode: \(maybe_opcode)")
            }
        }
    }

    mutating func lda_set_status() {
        z = a == 0
        n = (a & 0b10000000) != 0
    }

    mutating func lda_imm(_ cycles: inout UInt32) {
        a = fetchByte(&cycles)
        lda_set_status()
    }

    mutating func lda_zp(_ cycles: inout UInt32) {
        let zeroPageAddr = fetchByte(&cycles)
        a = readByte(zeroPageAddr, &cycles)
        lda_set_status()
    }

    mutating func lda_zpx(_ cycles: inout UInt32) {
        let zeroPageAddr = fetchByte(&cycles)
        a = readByte(zeroPageAddr + x, &cycles)
        lda_set_status()
    }

    mutating func jsr_abs(_ cycles: inout UInt32) {
        let addr = fetchWord(&cycles)
        memory[sp &- 1] = Byte(pc >> 8)
        memory[sp &- 2] = Byte(pc & 0xFF)
        sp &-= 2
        pc = addr
        cycles &-= 6
    }

    func toHex<T>(_ number: T) -> String
        where T : BinaryInteger {
        return NSString(format: "0x%02X", number as! CVarArg) as String
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