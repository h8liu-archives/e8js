exports.align = new (->
    pack = this
    pack.U16 = (offset) -> (offset >> 1 << 1)
    pack.U32 = (offset) -> (offset >> 2 << 2)
    return
)()
