import Foundation

public typealias Byte = UInt8
public typealias Word = UInt16

public let MAX_MEM: UInt32 = 0xFFFF

public enum Instruction: Byte, Sendable {
    case jsr = 0x20
    case lda = 0xA0
}

public enum AddressingMode: Byte, Sendable {
    case imm = 0x09 // Immediate
    case zp  = 0x05 // Zero Page
    case zpx = 0x15 // Zero Page, X
    case abs = 0x0D // Absolute
    case abx = 0x1D // Absolute, X
    case aby = 0x19 // Absolute, Y
    case idx = 0x01 // (Indirect, X)
    case idy = 0x11 // (Indirect), Y

    /** Not tested yet */
    case acc = 0x0A
    case rel = 0x10
    case imp = 0x00
    case ind = 0x02
}

public func decodeOpcode(_ opcode: Byte) -> (Instruction?, AddressingMode?)
{
    let instructionBits = opcode & 0b11100000 // Extract bits 7–5 (high nibble)
    let addressingBits  = opcode & 0b00011111 // Extract bits 4–0 (low nibble)

    print("instructionPart: \(toHex(instructionBits)), addressingPart: \(toHex(addressingBits))")

    // Map the extracted bits to corresponding enums
    let instruction = Instruction(rawValue: instructionBits)
    let addressingMode = AddressingMode(rawValue: addressingBits)

    print("Instruction: \(String(describing: instruction)), Addressing Mode: \(String(describing: addressingMode))")

    return (instruction, addressingMode)
}
public func toHex<T>(_ number: T) -> String
    where T : BinaryInteger
{
    return NSString(format: "0x%02X", number as! CVarArg) as String
}

public extension Word {
    static func + (lhs: Word, rhs: Byte) -> Word
    {
        return lhs &+ Word(rhs)
    }
}

public func opCode(_ instruction: Instruction, _ mode: AddressingMode) -> Byte
{
    return instruction.rawValue | mode.rawValue
}