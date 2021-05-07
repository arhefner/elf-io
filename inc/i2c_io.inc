PORT        EQU 6       ;Port used for i2c output

;These values use bit 0 of the output port as SDA, and bit 1 of
;the output port as SCL.
SDA_HIGH    EQU $FE     ;Mask to set SDA high (output bit is LOW)
SDA_LOW     EQU $01     ;Mask to set SDA low (output bit is HIGH)
SCL_HIGH    EQU $FD     ;Mask to set SCL high (output bit is LOW)
SCL_LOW     EQU $02     ;Mask to set SCL low (output bit is HIGH)
