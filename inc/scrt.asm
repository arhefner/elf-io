;------------------------------------------------------------------------
;This is an implementation of the call and return
;routines for the Standard Call and Return
;Technique (SCRT), as described in the User Manual
;for the CDP1802 COSMAC Microprocessor (MPM-201A).
EXITA:      SEP R3          ;R3 is pointing to the first
                            ;instruction in subroutine.
SCALL:      SEX R2          ;Point to stack.
            GHI R6          ;Push R6 onto stack to
            STXD            ;prepare it for pointing
            GLO R6          ;to arguments, and decrement
            STXD            ;to free location.
            GHI R3          ;Copy R3 into R6 to
            PHI R6          ;save the return address.
            GLO R3
            PLO R6
            LDA R6          ;Load the address of subroutine
            PHI R3          ;into R3.
            LDA R6
            PLO R3
            BR  EXITA       ;Branch to entry point of CALL
                            ;minus one byte. This leaves R4
                            ;pointing to CALL, allowing for
                            ;repeated calls.

EXITR:      SEP R3          ;Return to "MAIN" program.

SRET:       GHI R6          ;Copy R6 into R3
            PHI R3          ;R3 contains the return
            GLO R6          ;address
            PLO R3
            SEX 2           ;Point to stack.
            IRX             ;Point to saved old R6
            LDXA            ;Restore the contents
            PLO R6          ;of R6.
            LDX
            PHI R6
            BR  EXITR       ;Branch to entry point of RETPGM
                            ;minus one byte. This leaves R5
                            ;pointing to RETPGM for
                            ;following repeated calls.

;------------------------------------------------------------------------
;This routine can be used to initialize the SCRT/BIOS interface at the
;start of a program. It assumes the PC starts as R0. Place the address
;of this routine into any register and do a SEP to that register,
;followed by the initial value for the stack pointer, e.g:
;
;           LDI HIGH SCINIT
;           PHI RF
;           LDI LOW SCINIT
;           PLO RF
;           SEP RF
;           DW  STACKPTR
; START:    ;Control will return here with R3 = PC,
;           ;R4 = stdcall, R5 = stdret, R2 = stack ptr,
;           ;P = 3, X = 2
;
            SHARED SCINIT
SCINIT:     SEX R0          ;Point to location of init
            LDXA            ;stack pointer and copy
            PHI R2          ;to R2
            LDXA
            PLO R2
            SEX R2          ;Set stack pBUTointer
            LDI HIGH SCALL  ;Set R4 = SCRT call
            PHI R4
            LDI LOW SCALL
            PLO R4
            LDI HIGH SRET   ;Set R5 = SCRT return
            PHI R5
            LDI LOW SRET
            PLO R5
            GHI R0          ;Copy old PC to R3
            PHI R3
            GLO R0
            PLO R3
            SEP 3           ;return with R3 as PC
