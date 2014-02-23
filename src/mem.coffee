exports.mem = (->
    align = exports.align

    this.PageOffset = 12
    this.PageSize = 1 << PageOffset
    this.PageMask = PageSize - 1

    this.PageStart = (i) -> (i << PageOffset)
    this.PageId = (i) -> (i >> PageOffset)

    this.DataPage = ->
        bytes = new ArrayBuffer(PageSize)
        this.Read = (offset) -> bytes.getUint8 offset
        this.Write = (offset, b) -> bytes.setUint8 offset, b
        this.Bytes = bytes
        return

    this.NoopPage = ->
        this.Read = (offset) -> 0
        this.Write = (offset, b) -> return
        return

    noopPage = new NoopPage()

    this.Align = (p) ->
        page = p

        maskOffset = (offset) -> (offset & PageMask)
        offset8 = (offset) -> maskOffset(offset)
        offset16 = (offset) -> align.U16(maskOffset(offset))
        offset32 = (offset) -> align.U32(maskOffset(offset))

        writeU8 = (offset, value) ->
            page.Write(offset, value)
            return

        writeU16 = (offset, value) ->
            page.Write(offset, value & 0xff)
            page.Write(offset + 1, (value >> 8) & 0xff)
            return

        writeU32 = (offset, value) ->
            page.Write(offset, value & 0xff)
            page.Write(offset + 1, (value >> 8) & 0xff)
            page.Write(offset + 2, (value >> 16) & 0xff)
            page.Write(offset + 3, (value >> 24) & 0xff)

        readU8 = (offset) -> page.Read(offset)
        readU16 = (offset) ->
            ret = page.Read(offset)
            ret |= page.Read(offset + 1) << 8
            return ret
        readU32 = (offset) ->
            ret = page.Read(offset)
            ret |= page.Read(offset + 1) << 8
            ret |= page.Read(offset + 2) << 16
            ret |= page.Read(offset + 3) << 24
            return ret
        
        this.WriteU8 = (offset, value) -> writeU8(offset8(offset), value)
        this.WriteU16 = (offset, value) -> writeU16(offset16(offset), value)
        this.WriteU32 = (offset, value) -> writeU32(offset32(offset), value)
        this.ReadU8 = (offset) -> readU8(offset8(offset))
        this.ReadU16 = (offset) -> readU16(offset16(offset))
        this.ReadU32 = (offset) -> readU32(offset32(offset))

        return

    this.Memory = ->
        pages = {}
        thiz = this

        this.Get = (addr) ->
            id = PageId(addr)
            if !(id in pages)
                return noopPage
            return pages[id]

        this.Valid = (addr) -> (PageId(addr) in pages)
        this.Align = (addr) -> new Align(thiz.Get(addr))
        this.WriteU8 = (addr, value) -> thiz.Align(addr).WriteU8(addr, value)
        this.WriteU16 = (addr, value) -> thiz.Align(addr).WriteU16(addr, value)
        this.WriteU32 = (addr, value) -> thiz.Align(addr).WriteU32(addr, value)
        this.ReadU8 = (addr) -> thiz.Align(addr).ReadU8(addr)
        this.ReadU16 = (addr) -> thiz.Align(addr).ReadU16(addr)
        this.ReadU32 = (addr) -> thiz.Align(addr).ReadU32(addr)

        this.Map = (addr, page) -> pages[PageId(addr)] = page; return
        this.Unmap = (addr) -> delete pages[PageId(addr)]; return
        
        return

    return
)()
