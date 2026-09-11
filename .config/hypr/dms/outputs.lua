-- Primary 144Hz laptop panel
hl.monitor({ output = "desc:BOE 0x0C29 0x00000067", mode = "1920x1080@144", position = "0x0", scale = 1, vrr = 0, bitdepth = 8 })
-- Secondary external monitor (Native 74.97Hz)
hl.monitor({ output = "desc:Samsung Electric Company LF22T35 HK7X500372", mode = "1920x1080@74.97", position = "1920x0", scale = 1, vrr = 0, bitdepth = 8 })
-- Universal fallback: automatically enables any connected monitor
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
