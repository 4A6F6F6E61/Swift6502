typealias Byte = UInt8
typealias Word = UInt16

let MAX_MEM: UInt32 = 0xFFFF


print("Hello, world!")

var cpu = CPU()
cpu.reset()

cpu.memory[0xFFFC] = 0xA9
cpu.memory[0xFFFD] = 0x42

cpu.execute(2)

print(cpu.toString())