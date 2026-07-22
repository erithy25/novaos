/* ==========================================================================
 * NovaOS — Kernel Main
 * ==========================================================================
 * Haupteinstiegspunkt des Kernels.
 * Wird von boot.asm nach Multiboot2-Setup aufgerufen.
 * Initialisiert Subsysteme, zeigt Boot-Animation, startet Desktop.
 * ========================================================================== */

#include "vga.h"
#include "gdt.h"
#include "idt.h"
#include "pic.h"
#include "keyboard.h"
#include "pmm.h"
#include "timer.h"
#include "panic.h"
#include "boot_screen.h"
#include "desktop.h"

/* Multiboot2 Magic Number */
#define MULTIBOOT2_BOOTLOADER_MAGIC 0x36D76289

/* Kernel-Hauptfunktion */
void kernel_main(uint32_t magic, uint32_t multiboot_info) {
    (void)multiboot_info;

    /* VGA initialisieren — muss als erstes kommen */
    vga_init();

    /* Multiboot2 Magic prüfen */
    if (magic != MULTIBOOT2_BOOTLOADER_MAGIC) {
        kprint("Erwarteter Magic: ");
        kprint_hex(MULTIBOOT2_BOOTLOADER_MAGIC);
        kprint("  Erhalten: ");
        kprint_hex(magic);
        kprint("\n");
        kpanic("Kein gueltiger Multiboot2-Bootloader erkannt!");
    }

    /* Subsysteme initialisieren (leise — Boot-Screen zeigt Fortschritt) */
    gdt_init();
    pic_init();
    idt_init();
    pmm_init(32 * 1024);
    keyboard_init();

    /* Timer initialisieren (100 Hz — benötigt für delay_ms) */
    timer_init(100);

    /* Interrupts aktivieren */
    __asm__ volatile("sti");

    /* Boot-Animation anzeigen */
    boot_screen_run();

    /* Desktop starten */
    desktop_init();

    /* Endlosschleife — Kernel gibt nie die Kontrolle zurück */
    for (;;) {
        __asm__ volatile("hlt");
    }
}
