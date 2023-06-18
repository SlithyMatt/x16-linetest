.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

   jmp start

.include "x16.inc"

default_irq_vector:  .addr 0

bitmap_fn:           .byte "640grid.bin"
end_bitmap_fn:

; constants
VSYNC_BIT         = $01
LINE_BIT          = $02

.ifndef DISPLAY_SCALE
DISPLAY_SCALE     = 128
.endif

.ifndef CHANGE_LINE
CHANGE_LINE       = 200
.endif

BITMAP_PAL_OFFSET = VERA_L0_hscroll_h

; PETSCII
CHAR_Q            = $51
CLR               = $93

start:
   stz VERA_dc_video ; disable display

   ; scale display
   lda #DISPLAY_SCALE
   sta VERA_dc_hscale
   sta VERA_dc_vscale

   ; configure layer 0
   lda #$04 ; 1bpp bitmap
   sta VERA_L0_config
   lda #$01 ; 640 pixel wide bitmap at start of VRAM
   sta VERA_L0_tilebase

   ; load bitmap to VRAM
   lda #1 ; logical number
   ldx #8 ; device number (SD Card / emulator host FS)
   ldy #0 ; secondary address (0 = ignore file header)
   jsr SETLFS
   lda #(end_bitmap_fn-bitmap_fn)
   ldx #<bitmap_fn
   ldy #>bitmap_fn
   jsr SETNAM
   lda #2 ; VRAM bank (0) + 2
   ldx #0 ; the very top of VRAM
   ldy #0
   jsr LOAD

   ; enable layer 0
   lda #$11
   sta VERA_dc_video

   ; backup default RAM IRQ vector
   lda IRQVec
   sta default_irq_vector
   lda IRQVec+1
   sta default_irq_vector+1

   ; overwrite RAM IRQ vector with custom handler address
   sei ; disable IRQ while vector is changing
   lda #<custom_irq_handler
   sta IRQVec
   lda #>custom_irq_handler
   sta IRQVec+1
   ; set LINE interrupt to CHANGE_LINE
   lda #<CHANGE_LINE
   sta VERA_irqline_l
   lda #((CHANGE_LINE & $100 >> 1) | LINE_BIT | VSYNC_BIT) ; make VERA only generate LINE and VSYNC IRQs
   sta VERA_ien
   cli ; enable IRQ now that vector is properly set

@loop:
   wai
   jsr GETIN
   cmp #CHAR_Q
   bne @loop
   ; restore default IRQ vector
   sei
   lda default_irq_vector
   sta IRQVec
   lda default_irq_vector+1
   sta IRQVec+1
   lda #VSYNC_BIT
   sta VERA_ien
   cli
   ; reset screen mode
   lda #0
   clc
   jsr SCREEN_MODE
   ; enable layer 1 only
   lda #$21
   sta VERA_dc_video
   ; change color 1 back to white
   stz VERA_ctrl
   VERA_SET_ADDR $1FA02
   lda #$FF
   sta VERA_data0
   sta VERA_data0
   lda #CLR
   jsr CHROUT
   rts

custom_irq_handler:
   lda VERA_isr
   bit #VSYNC_BIT
   beq @change_color
   ; change color 1 back to white
   stz VERA_ctrl
   VERA_SET_ADDR $1FA02
   lda #$FF
   sta VERA_data0
   sta VERA_data0
   bra @continue
@change_color:
   ; change color 1 to red
   stz VERA_ctrl
   VERA_SET_ADDR $1FA02
   stz VERA_data0
   lda #$0F
   sta VERA_data0

@continue:
   ; reset IRQs
   lda #(LINE_BIT | VSYNC_BIT)
   sta VERA_isr
   ; continue to default IRQ handler
   jmp (default_irq_vector)
   ; RTI will happen after jump
