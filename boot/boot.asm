; =============================================================================
; NovaOS — Multiboot2 Entry Point
; =============================================================================
; Dieser Code wird als erstes nach dem Bootloader (GRUB2) ausgeführt.
; Er richtet den Stack ein und springt zum C-Kernel.
; =============================================================================

bits 32
section .multiboot
align 8

; --- Multiboot2 Header ---
MULTIBOOT2_MAGIC    equ 0xE85250D6
MULTIBOOT2_ARCH     equ 0            ; i386 protected mode
HEADER_LENGTH       equ multiboot_header_end - multiboot_header_start

multiboot_header_start:
    dd MULTIBOOT2_MAGIC                              ; Magic number
    dd MULTIBOOT2_ARCH                               ; Architecture (i386)
    dd HEADER_LENGTH                                 ; Header length
    dd -(MULTIBOOT2_MAGIC + MULTIBOOT2_ARCH + HEADER_LENGTH) ; Checksum

    ; --- End Tag ---
    align 8
    dw 0        ; type = 0 (end tag)
    dw 0        ; flags
    dd 8        ; size
multiboot_header_end:

; =============================================================================
; Stack — 16 KB, 16-Byte aligned
; =============================================================================
section .bss
align 16
stack_bottom:
    resb 16384          ; 16 KB Stack
stack_top:

; =============================================================================
; Entry Point — _start
; =============================================================================
section .text
global _start
extern kernel_main
extern gdt_flush

_start:
    ; Stack setzen
    mov esp, stack_top

    ; Multiboot2 Info-Pointer und Magic an kernel_main übergeben
    ; EAX = magic number, EBX = multiboot info struct pointer
    push ebx            ; Multiboot2 info struct
    push eax            ; Multiboot2 magic

    ; Interrupts deaktivieren bis IDT bereit ist
    cli

    ; Kernel-Hauptfunktion aufrufen
    call kernel_main

    ; Falls kernel_main zurückkehrt: CPU anhalten
    cli
.hang:
    hlt
    jmp .hang
