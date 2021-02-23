all:
	riscv64-unknown-elf-gcc -nostartfiles -nostdlib -T rom.link -march=rv32i -mabi=ilp32 counter.s -o counter
	riscv64-unknown-elf-objdump -d -M no-aliases,numeric counter
	riscv64-unknown-elf-objcopy -O binary counter counter.bin
	riscv64-unknown-elf-objcopy -O ihex counter counter.hex