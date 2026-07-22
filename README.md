# NovaOS

Ein Bare-Metal x86 Betriebssystem, geschrieben in C und x86 Assembly.
Kein Linux. Kein Windows. Keine libc. Läuft direkt auf der CPU.

## Features

- **Multiboot2 Boot** — Startet via GRUB2
- **VGA Textmodus** — Direkte Ausgabe auf 0xB8000 (80x25, 16 Farben)
- **GDT** — Flat Memory Model mit Kernel Code/Data Segmenten
- **IDT** — Exception Handler für alle 32 CPU Exceptions
- **8259A PIC** — Hardware-Interrupts auf IRQ 32-47 remapped
- **PS/2 Keyboard** — IRQ1-basierter Treiber mit Scancode→ASCII
- **Interactive Shell** — Befehle: `help`, `clear`, `about`, `mem`, `halt`
- **Physical Memory Manager** — Bitmap-basierte 4KB Page Allocation
- **Kernel Panic** — Fehlerbehandlung mit CPU-Halt

## Voraussetzungen

```bash
# macOS (Homebrew)
brew install nasm i686-elf-gcc i686-elf-grub xorriso qemu

# Linux (apt)
sudo apt install nasm gcc xorriso grub-pc-bin grub-common qemu-system-x86
```

## Build

```bash
make          # Kompiliert alles → novaos.iso
make run      # Startet in QEMU
make debug    # QEMU + GDB Server (Port 1234)
make clean    # Build-Artefakte löschen
```

## USB-Boot (echte Hardware)

```bash
# ISO auf USB-Stick schreiben (VORSICHT: richtiges Device wählen!)
sudo dd if=novaos.iso of=/dev/sdX bs=4M status=progress
```

## Architektur

```
boot/boot.asm      → Multiboot2 Entry, Stack Setup
boot/gdt.asm       → GDT/IDT Flush, ISR/IRQ Stubs
kernel/kernel.c    → Kernel Main, Subsystem-Init
kernel/vga.c       → VGA 80x25 Textmodus Treiber
kernel/gdt.c       → Global Descriptor Table
kernel/idt.c       → Interrupt Descriptor Table
kernel/pic.c       → 8259A PIC Controller
kernel/keyboard.c  → PS/2 Keyboard Treiber
kernel/shell.c     → Interaktive Kommandozeile
kernel/pmm.c       → Physical Memory Manager
kernel/panic.c     → Kernel Panic Handler
```

## Shell-Befehle

| Befehl  | Beschreibung                    |
|---------|---------------------------------|
| `help`  | Hilfe anzeigen                  |
| `clear` | Bildschirm leeren               |
| `about` | Systeminformationen             |
| `mem`   | Speicherinformationen           |
| `halt`  | System anhalten                 |
