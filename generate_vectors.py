import random

NUM_TESTS = 50

def int4_to_signed(val):
    """Convert 4-bit unsigned representation to signed integer."""
    return val - 16 if val >= 8 else val

def int8_to_signed(val):
    """Convert 8-bit unsigned representation to signed integer."""
    return val - 256 if val >= 128 else val

def to_hex(val, bits):
    """Convert integer to 2's complement hexadecimal string."""
    if val < 0:
        val = (1 << bits) + val
    format_str = f"{{:0{bits//4}X}}"
    return format_str.format(val)

def generate_vectors():
    print("Generating Golden Math Vectors for SWP MAC...")
    
    with open("test_vectors.txt", "w") as f:
        # Header for readability (Verilog testbenches can skip this or ignore lines starting with //)
        f.write("// Format: Mode(1 bit) A(8 bit) B(8 bit) Expected_Out(16 bit)\n")
        f.write("// Mode 0: 1x INT8 | Mode 1: 2x INT4\n")
        
        for _ in range(NUM_TESTS):
            # Randomly select mode: 0 for INT8, 1 for INT4
            mode = random.choice([0, 1])
            
            # Generate random 8-bit raw bit patterns (0 to 255)
            a_raw = random.randint(0, 255)
            b_raw = random.randint(0, 255)
            
            if mode == 0:
                # --- INT8 MULTIPLICATION ---
                a_signed = int8_to_signed(a_raw)
                b_signed = int8_to_signed(b_raw)
                
                p = a_signed * b_signed # 16-bit result
                
                # Write to file: Mode A B Result
                f.write(f"{mode} {to_hex(a_raw, 8)} {to_hex(b_raw, 8)} {to_hex(p, 16)}\n")
                
            else:
                # --- 2x INT4 MULTIPLICATION ---
                # Split the 8-bit raw buses into 4-bit high and low chunks
                a_high_raw = (a_raw >> 4) & 0xF
                a_low_raw = a_raw & 0xF
                b_high_raw = (b_raw >> 4) & 0xF
                b_low_raw = b_raw & 0xF
                
                # Convert chunks to signed 4-bit integers (-8 to +7)
                a_high = int4_to_signed(a_high_raw)
                a_low = int4_to_signed(a_low_raw)
                b_high = int4_to_signed(b_high_raw)
                b_low = int4_to_signed(b_low_raw)
                
                # Multiply the independent channels
                p_high = a_high * b_high # 8-bit result
                p_low = a_low * b_low    # 8-bit result
                
                # Pack the two 8-bit results into a single 16-bit expected output string
                p_high_hex = to_hex(p_high, 8)
                p_low_hex = to_hex(p_low, 8)
                
                # Write to file: Mode A B High_Result Low_Result
                f.write(f"{mode} {to_hex(a_raw, 8)} {to_hex(b_raw, 8)} {p_high_hex}{p_low_hex}\n")

    print(f"Success! {NUM_TESTS} test vectors written to 'test_vectors.txt'.")
    print("Day 1 [Desired Output] achieved.")

if __name__ == "__main__":
    generate_vectors()
