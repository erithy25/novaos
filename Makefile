# =============================================================================
# NovaOS — Build System
# =============================================================================
# Targets:
#   make       — Kompiliert alles, erzeugt novaos.iso
#   make run   — Startet in QEMU (qemu-system-i386)
#   make debug — Startet QEMU + GDB Server auf Port 1234
#   make clean — Löscht alle Build-Artefakte
# =============================================================================

# Cross-Compiler (i686-elf)
CC      = i686-elf-gcc
AS      = nasm
LD      = i686-elf-gcc

# Compiler-Flags
CFLAGS  = -std=c11 -ffreestanding -nostdlib \
           -fno-builtin -fno-stack-protector -fno-pic \
           -Wall -Wextra -O2 \
           -I kernel/

# Assembler-Flags
ASFLAGS = -f elf32

# Linker-Flags
LDFLAGS = -T linker.ld -ffreestanding -nostdlib -lgcc

# GRUB
GRUB_MKRESCUE = i686-elf-grub-mkrescue

# QEMU
QEMU    = qemu-system-i386

# Verzeichnisse
BUILD   = build
ISO_DIR = iso

# Quelldateien
ASM_SOURCES = boot/boot.asm boot/gdt.asm
C_SOURCES   = kernel/kernel.c \
              kernel/vga.c \
              kernel/gdt.c \
              kernel/idt.c \
              kernel/pic.c \
              kernel/keyboard.c \
              kernel/pmm.c \
              kernel/panic.c \
              kernel/string_util.c \
              kernel/timer.c \
              kernel/ui.c \
              kernel/boot_screen.c \
              kernel/desktop.c \
              kernel/app_calc.c \
              kernel/app_write.c \
              kernel/app_settings.c

# Objektdateien
ASM_OBJECTS = $(patsubst %.asm, $(BUILD)/%.o, $(ASM_SOURCES))
C_OBJECTS   = $(patsubst %.c, $(BUILD)/%.o, $(C_SOURCES))
OBJECTS     = $(ASM_OBJECTS) $(C_OBJECTS)

# Kernel Binary
KERNEL = $(BUILD)/novaos.bin

# ISO Image
ISO = novaos.iso

# =============================================================================
# Targets
# =============================================================================

.PHONY: all run debug clean dirs

# Standard-Target: ISO bauen
all: dirs $(ISO)

# ISO erzeugen mit grub-mkrescue
$(ISO): $(KERNEL)
	@echo "[ISO]  Erstelle $(ISO)..."
	@cp $(KERNEL) $(ISO_DIR)/boot/novaos.bin
	@$(GRUB_MKRESCUE) -o $(ISO) $(ISO_DIR) 2>/dev/null
	@echo "[DONE] $(ISO) erfolgreich erstellt!"

# Kernel linken
$(KERNEL): $(OBJECTS)
	@echo "[LINK] Linke Kernel..."
	@$(LD) $(LDFLAGS) -o $@ $^
	@echo "[DONE] Kernel bei $@"

# Assembly kompilieren
$(BUILD)/%.o: %.asm
	@mkdir -p $(dir $@)
	@echo "[ASM]  $<"
	@$(AS) $(ASFLAGS) -o $@ $<

# C kompilieren
$(BUILD)/%.o: %.c
	@mkdir -p $(dir $@)
	@echo "[CC]   $<"
	@$(CC) $(CFLAGS) -c -o $@ $<

# Build-Verzeichnisse erstellen
dirs:
	@mkdir -p $(BUILD)/boot $(BUILD)/kernel

# QEMU starten
run: all
	@echo "[QEMU] Starte NovaOS in QEMU..."
	@$(QEMU) -cdrom $(ISO) -m 32M -serial stdio

# QEMU mit GDB-Debug
debug: all
	@echo "[DEBUG] Starte NovaOS mit GDB-Server auf Port 1234..."
	@$(QEMU) -cdrom $(ISO) -m 32M -serial stdio -s -S

# Aufräumen
clean:
	@echo "[CLEAN] Lösche Build-Artefakte..."
	@rm -rf $(BUILD)
	@rm -f $(ISO)
	@rm -f $(ISO_DIR)/boot/novaos.bin
	@echo "[DONE] Sauber."
