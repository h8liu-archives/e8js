exports.inst = new (->
    pack = this

    this.Inst = (i) ->
        inst = i
        this.U32 = -> inst
        return

    opNoop = (c, f) -> return

    makeInstList = (m, n) ->
        ret = []
        for i in [0..n-1]
            ret.push(opNoop)
        for i in m
            ret[i] = m
        return ret

    this.OpRinst = 0
    this.OpJ = 0x02
    this.OpBeq = 0x04
    this.OpBne = 0x05

    this.OpAddi = 0x08
    this.OpSlti = 0x0A
    this.OpAndi = 0x0C
    this.OpOri = 0x0D
    this.OpLui = 0x0F
    
    this.OpLw = 0x23
    this.OpLhs = 0x21
    this.OpLhu = 0x25
    this.OpLbs = 0x20
    this.OpLbu = 0x24
    this.OpSw = 0x2B
    this.OpSh = 0x29
    this.OpSb = 0x28

    this.FnAdd = 0x20
    this.FnSub = 0x22
    this.FnAnd = 0x24
    this.FnOr = 0x25
    this.FnXor = 0x26
    this.FnNor = 0x27
    this.FnSlt = 0x2A
    this.FnMul = 0x18

    this.FnMulu = 0x19
    this.FnDiv = 0x1A
    this.FnDivu = 0x1B
    this.FnMod = 0x1C
    this.FnModu = 0x1D
    
    this.FnSll = 0x00
    this.FnSrl = 0x02
    this.FnSra = 0x03
    this.FnSllv = 0x04
    this.FnSrlv = 0x06
    this.FnSrav = 0x07

    mask32 = 0xffffffff

    this.Nreg = 32
    this.Nfreg = this.Nreg
    this.RegPC = this.Nreg - 1

    rInstList = makeInstList(
        FnAdd: (c, f) ->
            s = c.ReadReg(f.rs)
            t = c.ReadReg(f.rt)
            c.WriteReg(f.rd, (s + t) >> 0)
            return

        FnSub: (c, f) ->
            s = c.ReadReg(f.rs)
            t = c.ReadReg(f.rt)
            c.WriteReg(f.rd, (s - t) >> 0)
            return

        FnAnd: (c, f) ->
            s = c.ReadReg(f.rs)
            t = c.ReadReg(f.rt)
            c.WriteReg(f.rd, s & t)
            return

        Fnor: (c, f) ->
            s = c.ReadReg(f.rs)
            t = c.ReadReg(f.rt)
            c.WriteReg(f.rd, s | t)
            return

        FnXor: (c, f) ->
            s = c.ReadReg(f.rs)
            t = c.ReadREg(f.rt)
            c.WriteReg(f.rd, s ^ t)
            return

        FnNor: (c, f) ->
            s = c.ReadReg(f.rs)
            t = c.ReadReg(f.rt)
            c.WriteReg(f.rd, ~(s | t))
            return
        
        FnSlt: (c, f) ->
            s = c.ReadReg(f.rs) >> 0
            t = c.ReadReg(f.rt) >> 0
            if s < t
                v = 1
            else
                v = 0
            c.WriteReg(f.rd, v)
            return

        FnMul: (c, f) ->
            s = c.ReadReg(f.rs) >> 0
            t = c.ReadReg(f.rt) >> 0
            v = (s * t) & mask32
            c.WriteReg(f.rd, v)
            return

        FnMulu: (c, f) ->
            s = c.ReadReg(f.rs)
            t = c.ReadReg(f.rt)
            v = (s * t) & mask32
            c.WriteReg(f.rd, v)
            return

        FnDiv: (c, f) ->
            s = c.ReadReg(f.rs) >> 0
            t = c.ReadReg(f.rt) >> 0
            if t == 0
                c.WriteReg(f.rd, 0)
            else
                c.WriteReg(f.rd, (s / t) >> 0)
            return

        FnDivu: (c, f) ->
            s = c.ReadReg(f.rs)
            t = c.ReadReg(f.rt)
            if t == 0
                c.WriteReg(f.rd, 0)
            else
                c.WriteReg(f.rd, (s / t) >> 0)
            return

        FnMod: (c, f) ->
            s = c.ReadReg(f.rs) >> 0
            t = c.ReadReg(f.rt) >> 0
            if t == 0
                c.WriteReg(f.rd, 0)
            else
                c.WriteReg(f.rd, s % t)
            return

        FnModu: (c, f) ->
            s = c.ReadReg(f.rs)
            t = c.ReadReg(f.rt)
            if t == 0
                c.WriteReg(f.rd, 0)
            else
                c.WriteReg(f.rd, s % t)
            return

        FnSll: (c, f) ->
            t = c.ReadReg(f.rt)
            c.WriteReg(f.rd, t << f.shamt)
            return

        FnSrl: (c, f) ->
            t = c.ReadReg(f.rt)
            c.WriteReg(f.rd, t >> f.shamt)
            return

        FnSra: (c, f) ->
            t = c.ReadReg(f.rt)
            c.WriteReg(f.rd, t >>> f.shamt)
            return
        
        FnSllv: (c, f) ->
            s = c.ReadReg(f.rs)
            t = c.ReadReg(f.rt)
            if s > 32 || s < 0
                c.WriteReg(f.rd, 0)
            else
                c.WriteReg(f.rd, t << s)
            return

        FnSrlv: (c, f) ->
            s = c.ReadReg(f.rs)
            t = c.ReadReg(f.rt)
            if s > 32 || s < 0
                c.WriteReg(f.rd, 0)
            else
                c.WriteReg(f.rd, t >>> s)
            return

        FnSrav: (c, f) ->
            s = c.ReadReg(f.rs)
            t = c.ReadReg(f.rt)
            if s > 32 || s < 0
                c.WriteReg(f.rd, t >> 31)
            else
                c.WriteReg(f.rd, t >> s)
            return
    )

    memAddr = (c, f) -> ((c.ReadReg(f.rs) + f.ims) >> 0)
    signExt = (i) -> (i << 16 >> 16)
    signExt8 = (i) -> (i << 24 >> 24)

    instList = makeInstList(
        OpRinst: (c, f) ->
            inst = f.inst.U32()
            f.rd = (inst >> 11) & 0x1f
            f.shamt = (inst >> 6) & 0x1f
            funct = inst & 0x3f

            rInstList[funct](c, f)
            return

        OpJ: (c, f) ->
            pc = c.ReadReg(pack.RegPC)
            inst = f.inst.U32()
            pc = (pc + (inst << 6 >> 4)) >> 0
            c.WriteReg(pack.RegPC, pc)
            return

        OpBeq: (c, f) ->
            s = c.ReadReg(f.rs)
            t = c.ReadReg(f.rt)
            if s == t
                pc = c.ReadReg(pack.RegPC)
                pc = (pc + f.ims) >> 0
                c.WriteReg(pack.RegPC, pc)
            return

        OpBne: (c, f) ->
            s = c.ReadReg(f.rs)
            t = c.ReadReg(f.rt)
            if s != t
                pc = c.ReadReg(pack.RegPC)
                pc = (pc + f.ims) >> 0
                c.WriteReg(pack.RegPC, pc)
            return
     
        OpAddi: (c, f) ->
            s = c.ReadReg(f.rs)
            c.WriteReg(f.rt, (s + f.ims) >> 0)
            return

        OpLui: (c, f) ->
            t = c.ReadReg(f.rt)
            t = (t & 0xffff) | (f.im << 16)
            c.WriteReg(f.rt, t)
            return

        OpAndi: (c, f) ->
            s = c.ReadReg(f.rs)
            c.WriteReg(f.rt, s & f.im)
            return
        
        OpOri: (c, f) ->
            s = c.ReadReg(f.rs)
            c.WriteReg(f.rt, s | f.im)
            return

        OpSlti: (c, f) ->
            s = c.ReadReg(f.rs) >> 0
            if s < f.ims
                c.WriteReg(f.rt, 1)
            else
                c.WriteReg(f.rt, 0)
            return

        OpLw: (c, f) ->
            addr = memAddr(c, f)
            c.WriteReg(f.rt, c.ReadU32(addr))
            return

        OpLhs: (c, f) ->
            addr = memAddr(c, f)
            c.WriteReg(f.rt, signExt(c.ReadU16(addr)))
            return

        OpLhu: (c, f) ->
            addr = memAddr(c, f)
            c.WriteReg(f.rt, c.ReadU16(addr))
            return

        OpLbs: (c, f) ->
            addr = memAddr(c, f)
            c.WriteReg(f.rt, signExt8(c.ReadU8(addr)))
            return
        
        OpLbu: (c, f) ->
            addr = memAddr(c, f)
            c.WriteReg(f.rt, c.ReadU8(addr))
            return

        OpSw: (c, f) ->
            addr = memAddr(c, f)
            t = c.ReadReg(f.rt)
            c.WriteU32(addr, t)
            return

        OpSh: (c, f) ->
            addr = memAddr(c, f)
            t = c.ReadReg(f.rt) & 0xffff
            c.WriteU16(addr, t)
            return

        OpSb: (c, f) ->
            addr = memAddr(c, f)
            t = c.ReadReg(f.rt) & 0xff
            c.WriteU8(addr, t)
            return
    )

    opInst = (c, f) ->
        inst = f.inst.U32()
        op = (inst >> 26) & 0x3f
        f.rs = (inst >> 21) & 0x1f
        f.rt = (inst >> 16) & 0x1f
        f.im = inst & 0xffff
        f.ims = signExt(inst)

        instList[op](c, f)
        return

    return
)()
