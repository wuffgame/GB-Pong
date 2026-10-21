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

    ; Copy tile
    ld de, Tiles
    ld hl, $9000
    ld bc, TilesEnd - Tiles
    call MemCopy

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


    ; Initalize paddle01 in OAM - 0
    ld hl, STARTOF(OAM)
    ld a, 72 + 16 - 8
    ld [hli], a
    ld a, 155 + 8 - 4
    ld [hli], a
    ld a, 0
    ld [hli], a
    ld [hli], a
    ; Initalize paddle02 in OAM - 4
    ld a, 72 + 16
    ld [hli], a
    ld a, 155 + 8 - 4
    ld [hli], a
    ld a, 1
    ld [hli], a
    ld a, 0
    ld [hli], a
    ; Initalize paddle03 in OAM - 8
    ld a, 72 + 16 + 8
    ld [hli], a
    ld a, 155 + 8 - 4
    ld [hli], a
    ld a, 2
    ld [hli], a
    ld a, 0
    ld [hli], a
    ; Initalize paddle11 in OAM - 12
    ld a, 72 + 16 - 8
    ld [hli], a
    ld a, 0 + 8 + 4
    ld [hli], a
    ld a, 3
    ld [hli], a
    ld a, 0
    ld [hli], a
    ; Initalize paddle12 in OAM - 16
    ld a, 72 + 16
    ld [hli], a
    ld a, 0 + 8 + 4
    ld [hli], a
    ld a, 4
    ld [hli], a
    ld a, 0
    ld [hli], a
    ; Initalize paddle13 in OAM - 20
    ld a, 72 + 16 + 8
    ld [hli], a
    ld a, 0 + 8 + 4
    ld [hli], a
    ld a, 5
    ld [hli], a
    ld a, 0
    ld [hli], a
    ; Initalize ball in OAM - 24
    ld a, 72 + 16
    ld [hli], a
    ld a, 80 + 8 - 4
    ld [hli], a
    ld a, 6
    ld [hli], a
    ld a, 0
    ld [hli], a


    ; Initalize display registers
    ld a, %11100100
    ld [rOBP0], a

    ; Turn on LCD
    ld a, LCDC_ON | LCDC_OBJ_ON
    ld [rLCDC], a

    ; Initialize global variables
    ld a, 0
    ld [wFrameCounter], a
    ld [wCurKeys], a
    ld [wNewKeys], a
    ld a, 4
    ld [wBallDirection], a

Main:
    ; Wait until it's not VBlank
    ld a, [rLY]
    cp 144
    jp nc, Main
WaitVBlank2:
    ld a, [rLY]
    cp 144
    jp c, WaitVBlank2

    ; Check current keys
    call UpdateKeys

CheckUp:
    ld a, [wCurKeys]
    and a, PAD_UP
    jp z, CheckDown
Up:
    ; Move top right paddle one pixel to the up
    ld a, [STARTOF(OAM)]
    dec a
    cp a, 15
    jp z, Skip_paddle_move
    ld [STARTOF(OAM)], a

    ; Move middle right paddle one pixel to the up
    ld a, [STARTOF(OAM) + 4]
    dec a
    ld [STARTOF(OAM) + 4], a

    ; Move bottom right paddle one pixel to the up
    ld a, [STARTOF(OAM) + 8]
    dec a
    ld [STARTOF(OAM) + 8], a
    jp Ball_move

CheckDown:
    ld a, [wCurKeys]
    and a, PAD_DOWN
    jp z, Ball_move
Down:
    ; Move bottom right paddle one pixel to the down
    ld a, [STARTOF(OAM) + 8]
    inc a
    cp a, 160 - 7
    jp z, Skip_paddle_move
    ld [STARTOF(OAM) + 8], a

    ; Move top right paddle one pixel to the down
    ld a, [STARTOF(OAM)]
    inc a
    ld [STARTOF(OAM)], a

    ; Move middle right paddle one pixel to the down
    ld a, [STARTOF(OAM) + 4]
    inc a
    ld [STARTOF(OAM) + 4], a
Skip_paddle_move:

    ; Ball movement
Ball_move:    
    ld a, [wBallDirection]
    cp 0
    jr z, .move_up_left
    cp 1
    jr z, .move_left
    cp 2
    jr z, .move_down_left
    cp 3
    jr z, .move_up_right
    cp 4
    jr z, .move_right
    cp 5
    jr z, .move_down_right
    jr .end_ball_move

    .move_up_left:
        ld a, [STARTOF(OAM) + 24] ; y
        dec a
        ld [STARTOF(OAM) + 24], a
        ld a, [STARTOF(OAM) + 25] ; x
        dec a
        ld [STARTOF(OAM) + 25], a
        jr .end_ball_move
    .move_left:
        ld a, [STARTOF(OAM) + 25] ; x
        dec a
        ld [STARTOF(OAM) + 25], a
        jr .end_ball_move
    .move_down_left:
        ld a, [STARTOF(OAM) + 24] ; y
        inc a
        ld [STARTOF(OAM) + 24], a
        ld a, [STARTOF(OAM) + 25] ; x
        dec a
        ld [STARTOF(OAM) + 25], a
        jr .end_ball_move
    .move_up_right:
        ld a, [STARTOF(OAM) + 24] ; y
        dec a
        ld [STARTOF(OAM) + 24], a
        ld a, [STARTOF(OAM) + 25] ; x
        inc a
        ld [STARTOF(OAM) + 25], a
        jr .end_ball_move
    .move_right:
        ld a, [STARTOF(OAM) + 25] ; x
        inc a
        ld [STARTOF(OAM) + 25], a
        jr .end_ball_move
    .move_down_right:
        ld a, [STARTOF(OAM) + 24] ; y
        inc a
        ld [STARTOF(OAM) + 24], a
        ld a, [STARTOF(OAM) + 25] ; x
        inc a
        ld [STARTOF(OAM) + 25], a
        jr .end_ball_move


    .end_ball_move:
    jp Main

UpdateKeys:
  ; Poll half the controller
  ld a, JOYP_GET_BUTTONS
  call .onenibble
  ld b, a ; B7-4 = 1; B3-0 = unpressed buttons

  ; Poll the other half
  ld a, JOYP_GET_CTRL_PAD
  call .onenibble
  swap a ; A7-4 = unpressed directions; A3-0 = 1
  xor a, b ; A = pressed buttons + directions
  ld b, a ; B = pressed buttons + directions

  ; And release the controller
  ld a, JOYP_GET_NONE
  ldh [rJOYP], a

  ; Combine with previous wCurKeys to make wNewKeys
  ld a, [wCurKeys]
  xor a, b ; A = keys that changed state
  and a, b ; A = keys that changed to pressed
  ld [wNewKeys], a
  ld a, b
  ld [wCurKeys], a
  ret

.onenibble
  ldh [rJOYP], a ; switch the key matrix
  call .knownret ; burn 10 cycles calling a known ret
  ldh a, [rJOYP] ; ignore value while waiting for the key matrix to settle
  ldh a, [rJOYP]
  ldh a, [rJOYP] ; this read counts
  or a, $F0 ; A7-4 = 1; A3-0 = unpressed keys
.knownret
  ret

Tiles:
    dw `00000000
    dw `00030000
    dw `00030000
    dw `00030000
    dw `00030000
    dw `00030000
    dw `00030000
    dw `00000000
TilesEnd:

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


SECTION "Counter", WRAM0
wFrameCounter: db
wBallDirection: db

SECTION "Input Variables", WRAM0
wCurKeys: db
wNewKeys: db