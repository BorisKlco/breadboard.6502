.segment "CODE"
; ----------------------------------------------------------------------------
; SEE IF CONTROL-C TYPED
; ----------------------------------------------------------------------------
.ifdef W65
.include "w65_iscntc.s"
.endif
;!!! runs into "STOP"