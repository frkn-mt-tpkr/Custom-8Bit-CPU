#!/usr/bin/env python3
"""Assembler for the custom 8-bit SAP-1 CPU.

Translates an assembly source file into a hex file (one byte per line,
hexadecimal) that can be loaded into the CPU's RAM.

Instruction format:  [ OPCODE : 4 bits ][ ADDRESS : 4 bits ]

Usage:
    python assembler.py <input.asm> <output.hex>
"""

import sys

# 4-bit opcode for each mnemonic.
OPCODES = {
    "LDA": 0x2,
    "ADD": 0x1,
    "SUB": 0x3,
    "JMP": 0x4,
    "OUT": 0xE,
    "HLT": 0xF,
}

# Mnemonics that take an address operand; the rest ignore the lower nibble.
NEEDS_OPERAND = {"LDA", "ADD", "SUB", "JMP"}


def assemble_line(line):
    """Assemble one source line into a single byte (0..255).

    Returns None for a line that produces no code (blank or comment-only).
    Raises ValueError on a malformed line.
    """
    # Strip the comment and surrounding whitespace.
    code = line.split(";")[0].strip()
    if code == "":
        return None

    parts = code.split()
    mnemonic = parts[0].upper()

    # DB places a raw data byte in memory, e.g. "DB 13".
    if mnemonic == "DB":
        return int(parts[1], 0)

    if mnemonic not in OPCODES:
        raise ValueError(f"unknown mnemonic '{mnemonic}'")

    opcode = OPCODES[mnemonic]
    if mnemonic in NEEDS_OPERAND:
        addr = int(parts[1], 0)
        return (opcode << 4) | (addr & 0xF)
    else:
        return opcode << 4


def assemble(src_path, out_path):
    bytes_out = []
    with open(src_path) as f:
        for lineno, line in enumerate(f, start=1):
            try:
                b = assemble_line(line)
            except ValueError as e:
                sys.exit(f"{src_path}:{lineno}: error: {e}")
            if b is not None:
                bytes_out.append(b)

    with open(out_path, "w") as f:
        for b in bytes_out:
            f.write(f"{b:02X}\n")

    print(f"Wrote {len(bytes_out)} bytes to {out_path}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit("usage: python assembler.py <input.asm> <output.hex>")
    assemble(sys.argv[1], sys.argv[2])
