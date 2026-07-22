/* ==========================================================================
 * NovaOS — Linker Script
 * ==========================================================================
 * Kernel wird ab 1 MB (0x100000) gelinkt.
 * GRUB2 lädt den Kernel an diese Adresse.
 * ========================================================================== */

ENTRY(_start)

SECTIONS
{
    /* Kernel startet bei 1 MB */
    . = 0x100000;

    /* Multiboot Header — muss ganz am Anfang stehen */
    .multiboot ALIGN(8) :
    {
        *(.multiboot)
    }

    /* Code-Sektion */
    .text ALIGN(4096) :
    {
        *(.text)
    }

    /* Read-Only Daten */
    .rodata ALIGN(4096) :
    {
        *(.rodata)
        *(.rodata.*)
    }

    /* Initialisierte Daten */
    .data ALIGN(4096) :
    {
        *(.data)
    }

    /* Nicht-initialisierte Daten (BSS) */
    .bss ALIGN(4096) :
    {
        __bss_start = .;
        *(.bss)
        *(COMMON)
        __bss_end = .;
    }

    /* Ende des Kernels — nützlich für Memory Manager */
    __kernel_end = .;
}
