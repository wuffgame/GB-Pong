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

    ; Copy Paddle01 tile
    ld de, Paddle01
    ld hl, $8000
    ld bc, PaddleEnd01 - Paddle01
    call MemCopy

    ; Copy Paddle02 tile
    ld de, Paddle02
    ld hl, $8010
    ld bc, PaddleEnd02 - Paddle02
    call MemCopy

    ; Copy Paddle03 tile
    ld de, Paddle03
    ld hl, $8020
    ld bc, PaddleEnd03 - Paddle03
    call MemCopy

    ; Copy Paddle11 tile
    ld de, Paddle11
    ld hl, $8030
    ld bc, PaddleEnd11 - Paddle11
    call MemCopy

    ; Copy Paddle12 tile
    ld de, Paddle12
    ld hl, $8040
    ld bc, PaddleEnd12 - Paddle12
    call MemCopy

    ; Copy Paddle13
    ld de, Paddle13
    ld hl, $8050
    ld bc, PaddleEnd13 - Paddle13
    call MemCopy

    ; Copy Ball
    ld de, Ball
    ld hl, $8060
    ld bc, BallEnd - Ball
    call MemCopy

    ld a, 0
    ld b, 160
    ld hl, STARTOF(OAM)
CleanOam:
    ld [hli], a
    dec b
    jp nz, CleanOam


    ; Initalize paddle01 in OAM
    ld hl, STARTOF(OAM)
    ld a, 72 + 16 - 8
    ld [hli], a
    ld a, 155 + 8 - 4
    ld [hli], a
    ld a, 0
    ld [hli], a
    ld [hli], a
    ; Initalize paddle02 in OAM
    ld a, 72 + 16
    ld [hli], a
    ld a, 155 + 8 - 4
    ld [hli], a
    ld a, 1
    ld [hli], a
    ld a, 0
    ld [hli], a
    ; Initalize paddle03 in OAM
    ld a, 72 + 16 + 8
    ld [hli], a
    ld a, 155 + 8 - 4
    ld [hli], a
    ld a, 2
    ld [hli], a
    ld a, 0
    ld [hli], a
    ; Initalize paddle11 in OAM
    ld a, 72 + 16 - 8
    ld [hli], a
    ld a, 0 + 8 + 4
    ld [hli], a
    ld a, 3
    ld [hli], a
    ld a, 0
    ld [hli], a
    ; Initalize paddle12 in OAM
    ld a, 72 + 16
    ld [hli], a
    ld a, 0 + 8 + 4
    ld [hli], a
    ld a, 4
    ld [hli], a
    ld a, 0
    ld [hli], a
    ; Initalize paddle13 in OAM
    ld a, 72 + 16 + 8
    ld [hli], a
    ld a, 0 + 8 + 4
    ld [hli], a
    ld a, 5
    ld [hli], a
    ld a, 0
    ld [hli], a


    ; Initalize display registers
    ld a, %11100100
    ld [rOBP0], a

    ; Turn on LCD
    ld a, LCDC_ON | LCDC_OBJ_ON
    ld [rLCDC], a

Done:
    jp Done

Paddle01:
    dw `13331000
    dw `32223000
    dw `32223000
    dw `32223000
    dw `32223000
    dw `32223000
    dw `32223000
    dw `32223000
PaddleEnd01:

Paddle02:
    dw `32223000
    dw `32223000
    dw `32223000
    dw `32223000
    dw `32223000
    dw `32223000
    dw `32223000
    dw `32223000
PaddleEnd02:

Paddle03:
    dw `32223000
    dw `32223000
    dw `32223000
    dw `32223000
    dw `32223000
    dw `32223000
    dw `32223000
    dw `13331000
PaddleEnd03:

Paddle11:
    dw `00013331
    dw `00032223
    dw `00032223
    dw `00032223
    dw `00032223
    dw `00032223
    dw `00032223
    dw `00032223
PaddleEnd11:

Paddle12:
    dw `00032223
    dw `00032223
    dw `00032223
    dw `00032223
    dw `00032223
    dw `00032223
    dw `00032223
    dw `00032223
PaddleEnd12:

Paddle13:
    dw `00032223
    dw `00032223
    dw `00032223
    dw `00032223
    dw `00032223
    dw `00032223
    dw `00032223
    dw `00013331
PaddleEnd13:

Ball:
    dw `00033000
    dw `00311300
    dw `03111130
    dw `31111113
    dw `31111113
    dw `03111130
    dw `00311300
    dw `00033000
BallEnd:


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
