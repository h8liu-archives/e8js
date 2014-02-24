exports.inst = new (->
    pack = this

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

    this.Nfunct = 64
    this.Nop = 64

    rInstList = makeInstList({
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
    }, pack.Nfunct)

    memAddr = (c, f) -> ((c.ReadReg(f.rs) + f.ims) >> 0)
    signExt = (i) -> (i << 16 >> 16)
    signExt8 = (i) -> (i << 24 >> 24)

    instList = makeInstList({
        OpRinst: (c, f) ->
            inst = f.inst
            f.rd = (inst >> 11) & 0x1f
            f.shamt = (inst >> 6) & 0x1f
            funct = inst & 0x3f

            rInstList[funct](c, f)
            return

        OpJ: (c, f) ->
            pc = c.ReadReg(pack.RegPC)
            inst = f.inst
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
    }, pack.Nop)

    opInst = (c, f) ->
        inst = f.inst
        op = (inst >> 26) & 0x3f
        f.rs = (inst >> 21) & 0x1f
        f.rt = (inst >> 16) & 0x1f
        f.im = inst & 0xffff
        f.ims = signExt(inst)

        instList[op](c, f)
        return

    this.ALU = ->
        thiz = this
        this.fields = {}
        this.Inst = (c, inst) ->
            thiz.fields.inst = (inst >> 0)
            opInst(c, thiz.fields)
            return

    this.Rinst = (s, t, d, funct) ->
        ret = (s & 0x1f) << 21
        ret |= (t & 0x1f) << 16
        ret |= (d & 0x1f) << 11
        ret |= funct & 0x3f
        return ret

    this.RinstShamt = (s, t, d, shamt, funct) ->
        ret = (s & 0x1f) << 21
        ret |= (t & 0x1f) << 16
        ret |= (d & 0x1f) << 11
        ret |= (shamt & 0x1f) << 6
        ret |= funct & 0x3f
        return ret

    this.Iinst = (op, s, t, im) ->
        ret = (op & 0x3f) << 26
        ret |= (s & 0x1f) << 21
        ret |= (t & 0x1f) << 16
        ret |= im & 0xffff
        return ret

    this.Jinst = (ad) ->
        ret = (OpJ & 0x3f) << 26
        ret |= ad & 0x3ffffff
        return ret

    this.InstStr = (i) ->
        if i == 0
            return "noop"

        op = (i >> 26) & 0x3f
        if op == OpRinst
            rs = (i >> 21) & 0x1f
            rt = (i >> 16) & 0x1f
            rd = (i >> 11) & 0x1f
            shamt = (i >> 6) & 0x1f
            funct = i & 0x3f
            r3 = (op) -> (op+" $"+rd+", $"+rs+", $"+rt)
            r3r = (op) -> (op+" $"+rd+", $"+rt+", $"+rs)
            r3s = (op) -> (op+" $"+rd+", $"+rt+", "+shamt)

            switch op
                when pack.FnAdd then return r3 "add"
                when pack.FnSub then return r3 "sub"
                when pack.FnAnd then return r3 "and"
                when pack.FnOr then return r3 "or"
                when pack.FnXor then return r3 "xor"
                when pack.FnNor then return r3 "nor"
                when pack.FnSlt then return r3 "slt"
                when pack.FnMul then return r3 "mul"
                when pack.FnMulu then return r3 "mulu"
                when pack.FnDiv then return r3 "div"
                when pack.FnDiu then return r3 "divu"
                when pack.FnMod then return r3 "mod"
                when pack.FnModu then return r3 "modu"
                when pack.FnSll then return r3s "sll"
                when pack.FnSrl then return r3s "srl"
                when pack.FnSra then return r3s "sra"
                when pack.FnSllv then return r3r "sllv"
                when pack.FnSrlv then return r3r "srlv"
                when pack.FnSrav then return r3r "srav"
                else return "noop-r"+funct
        else if op == ObJ
            im = (i << 6) >> 6
            return "j "+im
        else
            rs = (i >> 21) & 0x1f
            rt = (i >> 16) & 0x1f
            im = i & 0xffff
            ims = i << 16 >> 16
            i2 = (op) -> (op+" $"+rt+", "+im)
            i3sr = (op) -> (op+" $"+rs+", $"+rt+", "+ims)
            i3s = (op) -> (op+" $"+rt+", $"+rs+", "+ims)
            i3a = (op) -> (op+" $"+rt+", "+ims+"($"+rs+")")

            switch op
                when pack.OpBeq then return i3sr "beq"
                when pack.OpBne then return i3sr "bne"
                when pack.OpAddi then return i3s "addi"
                when pack.OpSlti then return i3s "slti"
                when pack.OpAndi then return i3s "andi"
                when pack.OpOri then return i3s "ori"
                when pack.OpLui then return i2 "lui"
                when pack.OpLhs then return i3a "lhs"
                when pack.OpLhu then return i3a "lhu"
                when pack.OpLbu then return i3a "lbu"
                when pack.OpSw then return i3a "sw"
                when pack.OpSh then return i3a "sh"
                when pack.OpSb then return i3a "sb"

        return "noop-"+op

    return
)()
