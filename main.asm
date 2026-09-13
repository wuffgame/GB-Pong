INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]
    jp EntryPoint
    ds $150 - @, 0 ; Room for header

EntryPoint:

WaitVBlank:
    ld a, [rLY]
    cp 144
    jp c, WaitVBlank

    ; Turn LCD off
    ld a, 0
    ld [rLCDC], a

    ; Copy Paddle tile
    ld de, Paddle
    ld hl, $8000
    ld bc, PaddleEnd - Paddle
    call MemCopy

    ld a, 0
    ld b, 160
    ld hl, STARTOF(OAM)
CleanOam:
    ld [hli], a
    dec b
    jp nz, CleanOam


    ; Initalize first paddle in OAM
    ld hl, STARTOF(OAM)
    ld a, 72 + 16
    ld [hli], a
    ld a, 155 + 8
    ld [hli], a
    ld a, 0
    ld [hli], a
    ld [hli], a

    ; Initalize display registers
    ld a, %11100100
    ld [rOBP0], a

    ; Turn on LCD
    ld a, LCDC_ON | LCDC_OBJ_ON
    ld [rLCDC], a

Done:
    jp Done

Paddle:
    dw `13100000
    dw `32300000
    dw `32300000
    dw `32300000
    dw `32300000
    dw `32300000
    dw `32300000
    dw `13100000
PaddleEnd:


; @para de: Source
; @para hl: Destination
; @para bc: Lenght
MemCopy:
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or a, c
    jp nz, MemCopy
    ret
