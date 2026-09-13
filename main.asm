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

    ld de, Paddle
    ld hl, $8000
    ld bc, PaddleEnd - Paddle
    call MemCopy


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
