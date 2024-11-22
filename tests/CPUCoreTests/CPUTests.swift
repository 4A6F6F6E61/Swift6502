import XCTest
import Foundation
@testable import CPUCore

final class CPUTests: XCTestCase {

    func testLDAImmediate() {
        var cpu = CPU()
        
        // Load the LDA immediate instruction into memory
        cpu.memory[0xFFFC] = opCode(.lda, .imm) // LDA immediate opcode
        cpu.memory[0xFFFD] = 0x42 // Value to load into A
        
        do {
            try cpu.execute(2)
        } catch {
            XCTFail("Execution threw an unexpected error: \(error)")
        }
        
        // Assert the accumulator holds the correct value
        XCTAssertEqual(cpu.a, 0x42, "Accumulator did not load the correct immediate value.")
    }
    
    func testLDAZeroPage() {
        var cpu = CPU()
        
        // Set up memory
        cpu.memory[0xFFFC] = opCode(.lda, .zp) // LDA zero-page opcode
        cpu.memory[0xFFFD] = 0x10 // Address to read from
        cpu.memory[0x0010] = 0x37 // Value at zero-page address
        
        // Execute the instruction
        do {
            try cpu.execute(3)
        } catch {
            XCTFail("Execution threw an unexpected error: \(error)")
        }
        
        // Assert the accumulator holds the correct value
        XCTAssertEqual(cpu.a, 0x37, "Accumulator did not load the correct value from zero page.")
    }
    
    func testLDAZeroPageX() {
        var cpu = CPU()
        
        // Set up memory
        cpu.x = 0x05 // Set the X register
        cpu.memory[0xFFFC] = opCode(.lda, .zpx) // LDA zero-page,X opcode
        cpu.memory[0xFFFD] = 0x10 // Base address
        cpu.memory[0x0015] = 0x7F // Value at zero-page address + X
        
        // Execute the instruction
        do {
            try cpu.execute(4)
        } catch {
            XCTFail("Execution threw an unexpected error: \(error)")
        }
        
        // Assert the accumulator holds the correct value
        XCTAssertEqual(cpu.a, 0x7F, "Accumulator did not load the correct value from zero-page,X.")
    }

    func testLDAAbsolute() {
        var cpu = CPU()
        
        // Set up memory
        cpu.memory[0xFFFC] = opCode(.lda, .abs) // LDA absolute opcode
        cpu.memory[0xFFFD] = 0x00 // Low byte of address
        cpu.memory[0xFFFE] = 0x80 // High byte of address
        cpu.memory[0x8000] = 0x99 // Value at absolute address
        
        // Execute the instruction
        do {
            try cpu.execute(4)
        } catch {
            XCTFail("Execution threw an unexpected error: \(error)")
        }
        
        // Assert the accumulator holds the correct value
        XCTAssertEqual(cpu.a, 0x99, "Accumulator did not load the correct value from absolute address.")
    }

    func testLDAAbsoluteX() {
        var cpu = CPU()
        
        // Set up memory
        cpu.x = 0x01 // Set the X register
        cpu.memory[0xFFFC] = opCode(.lda, .abx) // LDA absolute,X opcode
        cpu.memory[0xFFFD] = 0x00 // Low byte of base address
        cpu.memory[0xFFFE] = 0x80 // High byte of base address
        cpu.memory[0x8001] = 0x88 // Value at absolute address + X
        
        // Execute the instruction
        do {
            try cpu.execute(4)
        } catch {
            XCTFail("Execution threw an unexpected error: \(error)")
        }
        
        // Assert the accumulator holds the correct value
        XCTAssertEqual(cpu.a, 0x88, "Accumulator did not load the correct value from absolute,X address.")
    }

    func testLDAAbsoluteY() {
        var cpu = CPU()
        
        // Set up memory
        cpu.y = 0x02 // Set the Y register
        cpu.memory[0xFFFC] = opCode(.lda, .aby) // LDA absolute,Y opcode
        cpu.memory[0xFFFD] = 0x00 // Low byte of base address
        cpu.memory[0xFFFE] = 0x80 // High byte of base address
        cpu.memory[0x8002] = 0x77 // Value at absolute address + Y
        
        // Execute the instruction
        do {
            try cpu.execute(4)
        } catch {
            XCTFail("Execution threw an unexpected error: \(error)")
        }
        
        // Assert the accumulator holds the correct value
        XCTAssertEqual(cpu.a, 0x77, "Accumulator did not load the correct value from absolute,Y address.")
    }

    func testLDAIndirectX() {
        var cpu = CPU()
        
        // Set up memory
        cpu.x = 0x04 // Set the X register
        cpu.memory[0xFFFC] = opCode(.lda, .idx) // LDA indirect,X opcode
        cpu.memory[0xFFFD] = 0x10 // Zero-page address
        cpu.memory[0x0014] = 0x00 // Low byte of indirect address
        cpu.memory[0x0015] = 0x90 // High byte of indirect address
        cpu.memory[0x9000] = 0x66 // Value at indirect address

        // Execute the instruction
        do {
            try cpu.execute(6)
        } catch {
            XCTFail("Execution threw an unexpected error: \(error)")
        }
        
        // Assert the accumulator holds the correct value
        XCTAssertEqual(cpu.a, 0x66, "Accumulator did not load the correct value from indirect,X address.")
    }

    func testLDAIndirectY() {
        var cpu = CPU()
        
        // Set up memory
        cpu.y = 0x04 // Set the Y register
        cpu.memory[0xFFFC] = opCode(.lda, .idy) // LDA indirect,Y opcode
        cpu.memory[0xFFFD] = 0x10 // Zero-page address
        cpu.memory[0x0010] = 0x00 // Low byte of indirect address
        cpu.memory[0x0011] = 0x90 // High byte of indirect address
        cpu.memory[0x9004] = 0xAB // Value at indirect address + Y

        print("Memory: \(cpu.memory)")
        
        // Execute the instruction
        do {
            try cpu.execute(5)
        } catch {
            XCTFail("Execution threw an unexpected error: \(error)")
        }
        
        // Assert the accumulator holds the correct value
        XCTAssertEqual(cpu.a, 0xAB, "Accumulator did not load the correct value from indirect,Y address.")
    }
}
