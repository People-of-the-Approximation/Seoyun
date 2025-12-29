# import serial
import struct

class VirtualDRAM:
    def __init__(self, filename="dram.bin", size_mb=1):
        self.filename = filename
        self.size = size_mb * 1024 * 1024

    def write(self, addr, data_bytes):
        if addr + len(data_bytes) > self.size:
            raise ValueError("DRAM Write Overflow")
        with open(self.filename, "r+b") as f:
            f.seek(addr)
            f.write(data_bytes)

    def read(self, addr, length):
        if addr + length > self.size:
            raise ValueError("DRAM Read Overflow")
        with open(self.filename, "rb") as f:
            f.seek(addr)
            data = f.read(length)
        return data
    
    def write_int_array(self, addr, int_list):
        packed_data = struct.pack(f'<{len(int_list)}i', *int_list)
        self.write(addr, packed_data)

    def read_int_array(self, addr, count):
        raw_bytes = self.read(addr, count * 4)
        return list(struct.unpack(f'<{count}i', raw_bytes))
    
    def write_float_array(self, addr, float_list):
        packed_data = struct.pack('f<{len(float_list)}f', *float_list)
        self.write(addr, packed_data)

    def read_float_array(self, addr, count):
        raw_bytes = self.read(addr, count*4)
        return list(struct.unpack(f'<{count}f', raw_bytes))
    

    
                                  
                                
    
