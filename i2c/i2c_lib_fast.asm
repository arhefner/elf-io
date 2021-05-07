            INCL "../inc/1802.inc"
            INCL "../inc/i2c_io.inc"

            ORG $4000

;------------------------------------------------------------------------
;This library contains routines to implement the i2c protocol using two
;bits of a parallel port. The two bits should be connected to open-
;collector or open-drain drivers such that when the output bit is HIGH,
;the corresponding i2c line (SDA or SCL) is pulled LOW.
;
;The current value of the output port is maintained in register RE.1.
;This allows the routines to manipulate the i2c outputs without
;disturbing the values of other bits on the output port.
;
;The routines are meant to be called using SCRT, with X=R2 being the
;stack pointer.

;------------------------------------------------------------------------
;This routine writes a message to the i2c bus.
;
;Parameters:
;   1: i2c_address     7-bit i2c address (1 byte)
;   2: num_bytes       number of bytes to write (1 byte)
;   3: address         address of message to be written (2 bytes)
;
;Example:
;   This call writes a 17 byte message to the i2c device at address 0x70:
;
;            CALL I2C_WRBUF
;            DB $70,17
;            DW BUFFER
;
; BUFFER:    DB $00
;            DB $06,$00,$5B,$00,$00,$00,$4F,$00
;            DB $66,$00,$00,$00,$00,$00,$00,$00
;
;Register usage:
;   RE.1 maintains the current state of the output port
;
            SHARED I2C_WRBUF
I2C_WRBUF:  GHI RA
            STXD
            GLO RA
            STXD
            GHI RD
            STXD
            GLO RD
            STXD
            GLO RE
            STXD
            GHI RF
            STXD
            GLO RF
            STXD

            ; Set up SEP function calls
            RLDI RA, I2C_WRITE_BYTE

            ; Read parameters
            LDA R6          ; Get i2c address
            SHL             ; Add write flag
            PHI RF
            LDA R6          ; Get count of bytes to write
            PLO RF          ; and save it.
            LDA R6          ; Get high address of buffer
            PHI RD
            LDA R6          ; Get low address of buffer
            PLO RD

            INCL "../inc/i2c_start.asm"

            SEP RA          ; Write address + write flag
.LOOP       LDA RD          ; Get next byte
            PHI RF
            SEP RA          ; Write data byte
            DEC RF
            GLO RF
            BNZ .LOOP

            INCL "../inc/i2c_stop.asm"

            IRX             ; Restore registers
            LDXA
            PLO RF
            LDXA
            PHI RF
            LDXA
            PLO RE
            LDXA
            PLO RD
            LDXA
            PHI RD
            LDXA
            PLO RA
            LDX
            PHI RA
            RETN

;------------------------------------------------------------------------
;This routine reads a message from the i2c bus.
;
;Parameters:
;   1: i2c_address     7-bit i2c address (1 byte)
;   2: num_bytes       number of bytes to read (1 byte)
;   3: address         address of message buffer (2 bytes)
;
;Example:
;   This call reads a 2 byte message from the i2c device at address 0x48.
;   On completion, the message is at TEMP_DATA:
;
;   READ_TEMP:  CALL I2C_RDBUF
;               DB $48,2
;               DW TEMP_DATA
;
;   TEMP_DATA:  DS 2
;
;Register usage:
;   RE.1 maintains the current state of the output port
;
            SHARED I2C_RDBUF
I2C_RDBUF:  GHI RA
            STXD
            GLO RA
            STXD
            GHI RB
            STXD
            GLO RB
            STXD
            GHI RD
            STXD
            GLO RD
            STXD
            GLO RE
            STXD
            GHI RF
            STXD
            GLO RF
            STXD

            ; Set up SEP function calls
            RLDI RA, I2C_WRITE_BYTE
            RLDI RB, I2C_READ_BYTE

            ; Read parameters
            LDA R6          ; Get i2c address
            SHL
            ORI $01         ; Add read flag
            PHI RF
            LDA R6          ; Save count of bytes
            SMI $01         ; minus one.
            PLO RF
            LDA R6          ; Get high address of buffer
            PHI RD
            LDA R6          ; Get low address of buffer
            PLO RD

            INCL "../inc/i2c_start.asm"

            SEP RA          ; Write address + read flag

            GLO RF
            BZ  .LAST

.LOOP:      SEP RB          ; Read next byte
            GHI RF
            STR RD
            INC RD

            ; ACK
            GHI RE
            ORI SDA_LOW     ; SDA LOW
            STR R2
            OUT PORT
            DEC R2
            ANI SCL_HIGH    ; SCL HIGH
            STR R2
            OUT PORT
            DEC R2
            ORI SCL_LOW     ; SCL LOW
            STR R2
            OUT PORT
            DEC R2
            PHI RE

            DEC RF
            GLO RF
            BNZ .LOOP

.LAST:      SEP RB          ; Read final byte
            GHI RF
            STR RD

            ; NAK
            GHI RE
            ANI SCL_HIGH    ; SCL HIGH
            STR R2
            OUT PORT
            DEC R2
            ORI SCL_LOW     ; SCL LOW
            STR R2
            OUT PORT
            DEC R2
            PHI RE

            INCL "../inc/i2c_stop.asm"

            IRX             ; Restore registers
            LDXA
            PLO RF
            LDXA
            PHI RF
            LDXA
            PLO RE
            LDXA
            PLO RD
            LDXA
            PHI RD
            LDXA
            PLO RB
            LDXA
            PHI RB
            LDXA
            PLO RA
            LDX
            PHI RA
            RETN

            ALIGN 256

;------------------------------------------------------------------------
;This routine reads a message from the i2c bus.
;
;Parameters:
;   1: i2c_address     7-bit i2c address (1 byte)
;   2: num_bytes       number of bytes to read (1 byte)
;   3: address         address of message buffer (2 bytes)
;
;Example:
;   This call reads a 2 byte message from the i2c device at address 0x48.
;   On completion, the message is at TEMP_DATA:
;
;   READ_TEMP:  CALL I2C_RDBUF
;               DB $48,2
;               DW TEMP_DATA
;
;   TEMP_DATA:  DS 2
;
;Register usage:
;   RE.1 maintains the current state of the output port
;
            SHARED I2C_RDREG
I2C_RDREG:  GHI RA
            STXD
            GLO RA
            STXD
            GHI RB
            STXD
            GLO RB
            STXD
            GLO RC
            STXD
            GHI RD
            STXD
            GLO RD
            STXD
            GLO RE
            STXD
            GHI RF
            STXD
            GLO RF
            STXD

            ; Set up SEP function calls
            RLDI RA, I2C_WRITE_BYTE
            RLDI RB, I2C_READ_BYTE

            ; Read parameters
            LDA R6          ; Get i2c address
            SHL             ; Add write flag
            PLO RC          ; Save shifted address
            PHI RF
            LDA R6          ; Get count of bytes to write
            PLO RF          ; and save it.

            INCL "../inc/i2c_start.asm"

            SEP RA          ; Write address + write flag
.WLOOP      LDA R6          ; Get next byte
            PHI RF
            SEP RA          ; Write next byte
            DEC RF
            GLO RF
            BNZ .WLOOP

            LDA R6          ; Save count of bytes
            SMI $01         ; minus one.
            PLO RF
            LDA R6          ; Get high address of buffer
            PHI RD
            LDA R6          ; Get low address of buffer
            PLO RD

            ; Repeated START
            INCL "../inc/i2c_start.asm"

            ; Rewrite the i2c address with read bit set
            GLO RC
            ORI $01
            PHI RF
            SEP RA

            GLO RF
            BZ  .LAST

.RLOOP:     SEP RB          ; Read next byte
            GHI RF
            STR RD
            INC RD

            ; ACK
            GHI RE
            ORI SDA_LOW     ; SDA LOW
            STR R2
            OUT PORT
            DEC R2
            ANI SCL_HIGH    ; SCL HIGH
            STR R2
            OUT PORT
            DEC R2
            ORI SCL_LOW     ; SCL LOW
            STR R2
            OUT PORT
            DEC R2
            PHI RE

            DEC RF
            GLO RF
            BNZ .RLOOP

.LAST:      SEP RB          ; Read final byte
            GHI RF
            STR RD

            ; NAK
            GHI RE
            ANI SDA_HIGH    ; SDA HIGH
            STR R2
            OUT PORT
            DEC R2
            ANI SCL_HIGH    ; SCL HIGH
            STR R2
            OUT PORT
            DEC R2
            ORI SCL_LOW     ; SCL LOW
            STR R2
            OUT PORT
            DEC R2
            PHI RE

            INCL "../inc/i2c_stop.asm"

            IRX             ; Restore registers
            LDXA
            PLO RF
            LDXA
            PHI RF
            LDXA
            PLO RE
            LDXA
            PLO RD
            LDXA
            PHI RD
            LDXA
            PLO RC
            LDXA
            PLO RB
            LDXA
            PHI RB
            LDXA
            PLO RA
            LDX
            PHI RA
            RETN

            ALIGN 256

;------------------------------------------------------------------------
;This routine writes one byte of data (MSB first) on the i2c bus.
;
;Register usage:
;   R2   points to an available memory location (typically top of stack)
;   RE.1 maintains the current state of the output port
;   RE.0 bit counter
;   RF.1 on entry, contains the value to be written to the bus
;
            SHARED I2C_WRITE_BYTE
            SEP R3
I2C_WRITE_BYTE:
            GHI RE
            ANI SDA_HIGH AND SCL_HIGH
            STXD

            ORI SCL_LOW
            STXD
            PHI RE
            GHI RF
            SHRC
            PHI RF
            GHI RE
            ANI SDA_HIGH AND SCL_HIGH
            LSDF
            ORI SDA_LOW
            STXD
            ORI SCL_LOW
            STXD

            PHI RE
            GHI RF
            SHRC
            PHI RF
            GHI RE
            ANI SDA_HIGH
            ORI SCL_LOW
            LSDF
            ORI SDA_LOW
            STXD
            ANI SCL_HIGH
            STXD
            ORI SCL_LOW
            STXD

            PHI RE
            GHI RF
            SHRC
            PHI RF
            GHI RE
            ANI SDA_HIGH
            ORI SCL_LOW
            LSDF
            ORI SDA_LOW
            STXD
            ANI SCL_HIGH
            STXD
            ORI SCL_LOW
            STXD

            PHI RE
            GHI RF
            SHRC
            PHI RF
            GHI RE
            ANI SDA_HIGH
            ORI SCL_LOW
            LSDF
            ORI SDA_LOW
            STXD
            ANI SCL_HIGH
            STXD
            ORI SCL_LOW
            STXD

            PHI RE
            GHI RF
            SHRC
            PHI RF
            GHI RE
            ANI SDA_HIGH
            ORI SCL_LOW
            LSDF
            ORI SDA_LOW
            STXD
            ANI SCL_HIGH
            STXD
            ORI SCL_LOW
            STXD

            PHI RE
            GHI RF
            SHRC
            PHI RF
            GHI RE
            ANI SDA_HIGH
            ORI SCL_LOW
            LSDF
            ORI SDA_LOW
            STXD
            ANI SCL_HIGH
            STXD
            ORI SCL_LOW
            STXD

            PHI RE
            GHI RF
            SHRC
            PHI RF
            GHI RE
            ANI SDA_HIGH
            ORI SCL_LOW
            LSDF
            ORI SDA_LOW
            STXD
            ANI SCL_HIGH
            STXD
            ORI SCL_LOW
            STXD

            PHI RE
            GHI RF
            SHRC
            PHI RF
            GHI RE
            ANI SDA_HIGH
            ORI SCL_LOW
            LSDF
            ORI SDA_LOW
            STXD
            ANI SCL_HIGH
            STXD
            ORI SCL_LOW
            STXD

            PHI RE

            IRX
            OUT PORT
            OUT PORT
            OUT PORT
            OUT PORT
            OUT PORT
            OUT PORT
            OUT PORT
            OUT PORT
            OUT PORT
            OUT PORT
            OUT PORT
            OUT PORT
            OUT PORT
            OUT PORT
            OUT PORT
            OUT PORT
            OUT PORT
            OUT PORT
            OUT PORT
            OUT PORT
            OUT PORT
            OUT PORT
            OUT PORT
            OUT PORT
            OUT PORT

            B1 .ACK
.NAK:       DEC R2
            PHI RE
            LDI $EE
            STR R2
            OUT 4
            DEC R2
            SKP
.ACK:       DEC R2
            GHI RE
            ORI SCL_LOW     ; SCL LOW
            STR R2
            OUT PORT
            DEC R2
            PHI RE
            BR  I2C_WRITE_BYTE - 1

            ALIGN 256

;------------------------------------------------------------------------
;This routine reads one byte of data (MSB first) from the i2c bus.
;
;Register usage:
;   R2   points to an available memory location (typically top of stack)
;   RE.1 maintains the current state of the output port
;   RE.0 bit counter
;   RB.0 on output, contains the value read from to the bus
;
            SHARED I2C_READ_BYTE
            SEP R3
I2C_READ_BYTE:
            LDI 8
            PLO RE
            GHI RE
            ANI SDA_HIGH    ; SDA HIGH
            STR R2
            OUT PORT
            DEC R2
            PHI RE
.NEXT_BIT:  GHI RE
            ANI SCL_HIGH    ; SCL HIGH
            STR R2
            OUT PORT
            DEC R2
            PHI RE          ; Update port data
            GHI RF
            SHL
            B1 .ZERO_BIT
            ORI $01
.ZERO_BIT:  PHI RF
            GHI RE
            ORI SCL_LOW     ; SCL LOW
            STR R2
            OUT PORT
            DEC R2
            PHI RE          ; Update port data
            DEC RE
            GLO RE
            BNZ .NEXT_BIT
            PHI RE
            BR  I2C_READ_BYTE - 1

;------------------------------------------------------------------------
;This routine attempts to clear a condition where a slave is out of
;sync and is holding the SDA line low.
;
;Register usage:
;   RE.1 maintains the current state of the output port
;
            SHARED I2C_CLEAR
I2C_CLEAR:  GHI RE
            ANI SDA_HIGH    ; SDA HIGH
            STR R2
            OUT PORT
            DEC R2
            BN1 .DONE       ; If SDA is high, we're done
.TOGGLE:    ORI SCL_LOW     ; SCL LOW
            STR R2
            OUT PORT
            DEC R2
            ANI SCL_HIGH    ; SCL HIGH
            STR R2
            OUT PORT
            DEC R2
            B1  .TOGGLE     ; Keep toggling SCL until SDA is high
.DONE:      PHI RE
            RETN

            END