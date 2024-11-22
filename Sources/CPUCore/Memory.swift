public class Memory {
    var mem: [Byte] = Array(repeating: 0, count: Int(MAX_MEM + 1))

    public subscript<T>(addr: T) -> Byte
        where T: BinaryInteger {
        get {
            return mem[Int(addr)]
        }
        set {
            mem[Int(addr)] = newValue
        }
    }
}