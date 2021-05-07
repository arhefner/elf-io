;------------------------------------------------------------------------
;This routine creates a START condition on the i2c bus.
;
;Register usage:
;   R2   points to an available memory location (typically top of stack)
;   RE.1 maintains the current state of the output port
;
            GHI RE
            ANI SDA_HIGH    ; SDA HIGH
            STR R2
            OUT PORT
            DEC R2
            ANI SCL_HIGH    ; SCL HIGH
            STR R2
            OUT PORT
            DEC R2
            ORI SDA_LOW     ; SDA LOW
            STR R2
            OUT PORT
            DEC R2
            ORI SCL_LOW     ; SCL LOW
            STR R2
            OUT PORT
            DEC R2
            PHI RE          ; Update port data
