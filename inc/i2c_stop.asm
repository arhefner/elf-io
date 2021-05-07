;------------------------------------------------------------------------
;This routine creates a STOP condition on the i2c bus.
;
;Register usage:
;   R2   points to an available memory location (typically top of stack)
;   RE.1 maintains the current state of the output port
;
            GHI RE
            ORI SDA_LOW     ; SDA LOW
            STR R2
            OUT PORT
            DEC R2
            ANI SCL_HIGH    ; SCL HIGH
            STR R2
            OUT PORT
            DEC R2
            ANI SDA_HIGH    ; SDA HIGH
            STR R2
            OUT PORT
            DEC R2
            PHI RE          ; Update port data
