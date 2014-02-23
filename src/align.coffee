exports.align = new (->
    this.U16 = (offset) -> (offset >> 1 << 1)
    this.U32 = (offset) -> (offset >> 2 << 2)
    return
)()
