            INCL "../inc/1802.inc"

STKSIZE     EQU 256

SYNC_LEN    EQU $0468
START_LEN   EQU $0224
ONE_THRESH  EQU $0080

            ORG $100

            SHARED NEC_IR_IN
NEC_IR_IN:  GLO RA              ; Save RA
            STXD
            GHI RA
            STXD

            LDI $80             ; Init R7|R8 = $80000000
            PHI R7
            LDI $00
            PLO R7
            PHI R8
            PLO R8

.WAIT:      BN2 .WAIT           ; Wait for sync pulse.

            LDI $00             ; Time sync pulse by incrementing
            PHI RA              ; RA as long as the signal is
            PLO RA              ; present.
.SYNC:      INC RA
            B2 .SYNC
            GLO RA              ; If sync pulse is not correct
            SMI LOW SYNC_LEN    ; length, then branch to ERR
            GHI RA              ; with DF = 0.
            SMBI HIGH SYNC_LEN
            BL .STOP

            LDI $00             ; Time period after sync pulse
            PHI RA
            PLO RA
.START:     INC RA
            BN2 .START
            GLO RA              ; If length is not correct
            SMI LOW START_LEN   ; (this would include repeat
            GHI RA              ; codes), then branch to ERR
            SMBI HIGH START_LEN ; with DF = 0.
            BL .STOP

            LDI 32              ; Read 32 bits
            PLO RC

            LDI $00             ; Time initial pulse
            PHI RA
            PLO RA
.MARK:      INC RA
            B2 .MARK

            LDI $00             ; Time space
            PHI RA
            PLO RA
.SPACE:     INC RA
            BN2 .SPACE
            RSHR R7             ; Shift R7|R8 right
            RSHRC R8
;            GHI R7
;            SHR
;            PHI R7
;            GLO R7
;            SHRC
;            PLO R7
;            GHI R8
;            SHRC
;            PHI R8
;            GLO R8
;            SHRC
;            PLO R8

            GLO RA              ; If it's a long space
            SMI LOW ONE_THRESH  ; then the data bit is
            GHI RA              ; a 1, else 0.
            SMBI HIGH ONE_THRESH
            GHI R7
            LSNF
            ORI $80
            PHI R7

            DEC RC
            GLO RC
            BNZ .MARK

            LDI $01             ; Set DF=1 (success)
            SHR

.STOP:      B2 .STOP            ; Wait for end pulse

            IRX
            LDXA
            PHI RA
            LDX
            PLO RA
            RETN

            END
