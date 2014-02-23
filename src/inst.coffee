exports.inst = new (->
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
        
        # TODO: here
    )
    
    instList = makeInstList(
        OpRinst: (c, f) ->
            inst = f.inst.U32()
            f.rd = (inst >> 11) & 0x1f
            f.shamt = (inst >> 6) & 0x1f
            funct = inst & 0x3f

            rInstList[funct](c, f)
    )

    return
)()
