            INCL "../inc/1802.inc"
            INCL "nec_ir.inc"

STKSIZE     EQU 256

            ORG $1000

            LDI HIGH SCINIT
            PHI RF
            LDI LOW SCINIT
            PLO RF
            SEP RF
            DW  STKPTR

LOOP:       CALL NEC_IR_IN
            BNF LOOP

            GHI R7
            STR R2
            GLO R7
            XOR
            XRI $FF
            BNZ LOOP

            GHI R8
            STR R2
            GLO R8
            XOR
            XRI $FF
            BNZ LOOP

            GLO R7
            STR R2
            OUT 4
            DEC R2

            BR LOOP

            INCL "../inc/scrt.asm"

STACK:      DS STKSIZE
STKPTR:     EQU $-1

            END
