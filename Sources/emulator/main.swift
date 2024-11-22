import CPUCore

var cpu = CPU()
        
// Set up memory
cpu.y = 0x04 // Set the Y register
cpu.memory[0xFFFC] = opCode(.lda, .idy) // LDA indirect,Y opcode
cpu.memory[0xFFFD] = 0x10 // Zero-page address
cpu.memory[0x0010] = 0x00 // Low byte of indirect address
cpu.memory[0x0011] = 0x90 // High byte of indirect address
cpu.memory[0x9004] = 0xAB // Value at indirect address + Y

// Execute the instruction
do {
    try cpu.execute(5)
} catch {
    print("Error: \(error)")
}
print(cpu.toString())