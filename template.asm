            INCL "../inc/1802.inc"

STKSIZE     EQU 256

            ORG $1000

            ; Initialize SCRT routines
            LDI HIGH SCINIT
            PHI RF
            LDI LOW SCINIT
            PLO RF
            SEP RF
            DW  STKPTR

            ; Main program
            IDL

            ; Include SCRT routines
            INCL "../inc/scrt.asm"

            STACK:      DS STKSIZE
STKPTR:     EQU $-1

            END
