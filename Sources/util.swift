import Foundation

typealias Byte = UInt8
typealias Word = UInt16

let MAX_MEM: UInt32 = 0xFFFF

enum Instruction: Byte {
    case jsr = 0x20
    case lda = 0xA0
}

enum AddressingMode: Byte {
    case imm = 0x09
    case zp  = 0x05
    case zpx = 0x15
    case abs = 0x0D
    case abx = 0x1D
    case aby = 0x19
    case idx = 0x01
    case idy = 0x11
    case acc = 0x0A
    case rel = 0x10
    case imp = 0x00
    // Add other addressing modes as needed
}

func decodeOpcode(_ opcode: Byte) -> (Instruction?, AddressingMode?) {
    let instructionBits = opcode & 0b11100000 // Extract bits 7–5 (high nibble)
    let addressingBits  = opcode & 0b00011111 // Extract bits 4–0 (low nibble)

    print("instructionPart: \(toHex(instructionBits)), addressingPart: \(toHex(addressingBits))")

    // Map the extracted bits to corresponding enums
    let instruction = Instruction(rawValue: instructionBits)
    let addressingMode = AddressingMode(rawValue: addressingBits)

    print("Instruction: \(instruction), Addressing Mode: \(addressingMode)")

    return (instruction, addressingMode)
}
func toHex<T>(_ number: T) -> String
    where T : BinaryInteger {
    return NSString(format: "0x%02X", number as! CVarArg) as String
}