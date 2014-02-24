exports.mem = new (->
    pack = this

    align = exports.align

    pack.PageOffset = 12
    pack.PageSize = 1 << pack.PageOffset
    pack.PageMask = pack.PageSize - 1

    pack.PageStart = (i) -> (i << pack.PageOffset)
    pack.PageId = (i) -> (i >> pack.PageOffset)

    pack.DataPage = ->
        self = this
        bytes = new ArrayBuffer(pack.PageSize)
        self.Read = (offset) -> bytes.getUint8 offset
        self.Write = (offset, b) -> bytes.setUint8 offset, b
        self.Bytes = bytes
        return

    pack.NoopPage = ->
        self = this
        self.Read = (offset) -> 0
        self.Write = (offset, b) -> return
        return

    noopPage = new pack.NoopPage()

    pack.Align = (p) ->
        self = this

        page = p

        maskOffset = (offset) -> (offset & pack.PageMask)
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
        
        self.WriteU8 = (offset, value) -> writeU8(offset8(offset), value)
        self.WriteU16 = (offset, value) -> writeU16(offset16(offset), value)
        self.WriteU32 = (offset, value) -> writeU32(offset32(offset), value)
        self.ReadU8 = (offset) -> readU8(offset8(offset))
        self.ReadU16 = (offset) -> readU16(offset16(offset))
        self.ReadU32 = (offset) -> readU32(offset32(offset))

        return

    pack.Memory = ->
        self = this
        pages = {}

        self.Get = (addr) ->
            id = pack.PageId(addr)
            if !(id in pages)
                return noopPage
            return pages[id]

        self.Valid = (addr) -> (pack.PageId(addr) in pages)
        self.Align = (addr) -> new Align(self.Get(addr))

        self.WriteU8 = (addr, value) ->
            self.Align(addr).WriteU8(addr, value)
        self.WriteU16 = (addr, value) ->
            self.Align(addr).WriteU16(addr, value)
        self.WriteU32 = (addr, value) ->
            self.Align(addr).WriteU32(addr, value)

        self.ReadU8 = (addr) -> self.Align(addr).ReadU8(addr)
        self.ReadU16 = (addr) -> self.Align(addr).ReadU16(addr)
        self.ReadU32 = (addr) -> self.Align(addr).ReadU32(addr)

        self.Map = (addr, page) ->
            pages[pack.PageId(addr)] = page
            return

        self.Unmap = (addr) ->
            delete pages[pack.PageId(addr)]
            return
        
        return

    return
)()
