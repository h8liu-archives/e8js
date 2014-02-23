align = require("../e8").align

o = (b) ->
    if !b
        e = new Error("test failed")
        console.log(e.stack)
    return

o(align.U32(3) == 0)
o(align.U16(3) == 2)
o(align.U32(1024) == 1024)
o(align.U32(1025) == 1024)
o(align.U32(1026) == 1024)
o(align.U32(1027) == 1024)
    

