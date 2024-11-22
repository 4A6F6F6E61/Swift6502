
var cpu = CPU()
cpu.reset()

cpu.memory[0xFFFC] = 0xB9
cpu.memory[0xFFFD] = 0x42

cpu.execute(3)

print(cpu.toString())