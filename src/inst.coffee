exports.inst = new (->
    pack = this

    opNoop = (c, f) -> return

    makeInstList = (m, n) ->
        ret = []
        for i in [0..n-1]
            ret.push(opNoop)
        for i of m
            ret[i] = m[i]
        return ret

    pack.OpRinst = 0
    pack.OpJ = 0x02
    pack.OpBeq = 0x04
    pack.OpBne = 0x05

    pack.OpAddi = 0x08
    pack.OpSlti = 0x0A
    pack.OpAndi = 0x0C
    pack.OpOri = 0x0D
    pack.OpLui = 0x0F
    
    pack.OpLw = 0x23
    pack.OpLhs = 0x21
    pack.OpLhu = 0x25
    pack.OpLbs = 0x20
    pack.OpLbu = 0x24
    pack.OpSw = 0x2B
    pack.OpSh = 0x29
    pack.OpSb = 0x28

    pack.FnAdd = 0x20
    pack.FnSub = 0x22
    pack.FnAnd = 0x24
    pack.FnOr = 0x25
    pack.FnXor = 0x26
    pack.FnNor = 0x27
    pack.FnSlt = 0x2A
    pack.FnMul = 0x18

    pack.FnMulu = 0x19
    pack.FnDiv = 0x1A
    pack.FnDivu = 0x1B
    pack.FnMod = 0x1C
    pack.FnModu = 0x1D
    
    pack.FnSll = 0x00
    pack.FnSrl = 0x02
    pack.FnSra = 0x03
    pack.FnSllv = 0x04
    pack.FnSrlv = 0x06
    pack.FnSrav = 0x07

    mask32 = 0xffffffff

    pack.Nreg = 32
    pack.Nfreg = pack.Nreg
    pack.RegPC = pack.Nreg - 1

    pack.Nfunct = 64
    pack.Nop = 64

    insts = {}
    insts[pack.FnAdd] = (c, f) ->
        s = c.ReadReg(f.rs)
        t = c.ReadReg(f.rt)
        c.WriteReg(f.rd, (s + t) >> 0)
        return
    insts[pack.FnSub] = (c, f) ->
        s = c.ReadReg(f.rs)
        t = c.ReadReg(f.rt)
        c.WriteReg(f.rd, (s - t) >> 0)
        return
    insts[pack.FnAnd] = (c, f) ->
        s = c.ReadReg(f.rs)
        t = c.ReadReg(f.rt)
        c.WriteReg(f.rd, s & t)
        return
    insts[pack.Fnor] = (c, f) ->
        s = c.ReadReg(f.rs)
        t = c.ReadReg(f.rt)
        c.WriteReg(f.rd, s | t)
        return
    insts[pack.FnXor] = (c, f) ->
        s = c.ReadReg(f.rs)
        t = c.ReadREg(f.rt)
        c.WriteReg(f.rd, s ^ t)
        return
    insts[pack.FnNor] = (c, f) ->
        s = c.ReadReg(f.rs)
        t = c.ReadReg(f.rt)
        c.WriteReg(f.rd, ~(s | t))
        return
    insts[pack.FnSlt] = (c, f) ->
        s = c.ReadReg(f.rs) >> 0
        t = c.ReadReg(f.rt) >> 0
        if s < t
            v = 1
        else
            v = 0
        c.WriteReg(f.rd, v)
        return
    insts[pack.FnMul] = (c, f) ->
        s = c.ReadReg(f.rs) >> 0
        t = c.ReadReg(f.rt) >> 0
        v = (s * t) & mask32
        c.WriteReg(f.rd, v)
        return
    insts[pack.FnMulu] = (c, f) ->
        s = c.ReadReg(f.rs)
        t = c.ReadReg(f.rt)
        v = (s * t) & mask32
        c.WriteReg(f.rd, v)
        return
    insts[pack.FnDiv] = (c, f) ->
        s = c.ReadReg(f.rs) >> 0
        t = c.ReadReg(f.rt) >> 0
        if t == 0
            c.WriteReg(f.rd, 0)
        else
            c.WriteReg(f.rd, (s / t) >> 0)
        return
    insts[pack.FnDivu] = (c, f) ->
        s = c.ReadReg(f.rs)
        t = c.ReadReg(f.rt)
        if t == 0
            c.WriteReg(f.rd, 0)
        else
            c.WriteReg(f.rd, (s / t) >> 0)
        return
    insts[pack.FnMod] = (c, f) ->
        s = c.ReadReg(f.rs) >> 0
        t = c.ReadReg(f.rt) >> 0
        if t == 0
            c.WriteReg(f.rd, 0)
        else
            c.WriteReg(f.rd, s % t)
        return
    insts[pack.FnModu] = (c, f) ->
        s = c.ReadReg(f.rs)
        t = c.ReadReg(f.rt)
        if t == 0
            c.WriteReg(f.rd, 0)
        else
            c.WriteReg(f.rd, s % t)
        return
    insts[pack.FnSll] = (c, f) ->
        t = c.ReadReg(f.rt)
        c.WriteReg(f.rd, t << f.shamt)
        return
    insts[pack.FnSrl] = (c, f) ->
        t = c.ReadReg(f.rt)
        c.WriteReg(f.rd, t >> f.shamt)
        return
    insts[pack.FnSra] = (c, f) ->
        t = c.ReadReg(f.rt)
        c.WriteReg(f.rd, t >>> f.shamt)
        return
    insts[pack.FnSllv] = (c, f) ->
        s = c.ReadReg(f.rs)
        t = c.ReadReg(f.rt)
        if s > 32 || s < 0
            c.WriteReg(f.rd, 0)
        else
            c.WriteReg(f.rd, t << s)
        return
    insts[pack.FnSrlv] = (c, f) ->
        s = c.ReadReg(f.rs)
        t = c.ReadReg(f.rt)
        if s > 32 || s < 0
            c.WriteReg(f.rd, 0)
        else
            c.WriteReg(f.rd, t >>> s)
        return
    insts[pack.FnSrav] = (c, f) ->
        s = c.ReadReg(f.rs)
        t = c.ReadReg(f.rt)
        if s > 32 || s < 0
            c.WriteReg(f.rd, t >> 31)
        else
            c.WriteReg(f.rd, t >> s)
        return
    rInstList = makeInstList(insts, pack.Nfunct)

    memAddr = (c, f) -> ((c.ReadReg(f.rs) + f.ims) >> 0)
    signExt = (i) -> (i << 16 >> 16)
    signExt8 = (i) -> (i << 24 >> 24)

    insts = {}
    insts[pack.OpRinst] = (c, f) ->
        inst = f.inst
        f.rd = (inst >> 11) & 0x1f
        f.shamt = (inst >> 6) & 0x1f
        funct = inst & 0x3f

        rInstList[funct](c, f)
        return
    insts[pack.OpJ] = (c, f) ->
        pc = c.ReadReg(pack.RegPC)
        inst = f.inst
        pc = (pc + (inst << 6 >> 4)) >> 0
        c.WriteReg(pack.RegPC, pc)
        return
    insts[pack.OpBeq] = (c, f) ->
        s = c.ReadReg(f.rs)
        t = c.ReadReg(f.rt)
        if s == t
            pc = c.ReadReg(pack.RegPC)
            pc = (pc + (f.ims << 2)) >> 0
            c.WriteReg(pack.RegPC, pc)
        return
    insts[pack.OpBne] = (c, f) ->
        s = c.ReadReg(f.rs)
        t = c.ReadReg(f.rt)
        if s != t
            pc = c.ReadReg(pack.RegPC)
            pc = (pc + (f.ims << 2)) >> 0
            c.WriteReg(pack.RegPC, pc)
        return
    insts[pack.OpAddi] = (c, f) ->
        s = c.ReadReg(f.rs)
        c.WriteReg(f.rt, (s + f.ims) >> 0)
        return
    insts[pack.OpLui] = (c, f) ->
        t = f.im << 16
        c.WriteReg(f.rt, t)
        return
    insts[pack.OpAndi] = (c, f) ->
        s = c.ReadReg(f.rs)
        c.WriteReg(f.rt, s & f.im)
        return
    insts[pack.OpOri] = (c, f) ->
        s = c.ReadReg(f.rs)
        c.WriteReg(f.rt, s | f.im)
        return
    insts[pack.OpSlti] = (c, f) ->
        s = c.ReadReg(f.rs) >> 0
        if s < f.ims
            c.WriteReg(f.rt, 1)
        else
            c.WriteReg(f.rt, 0)
        return
    insts[pack.OpLw] = (c, f) ->
        addr = memAddr(c, f)
        c.WriteReg(f.rt, c.ReadU32(addr))
        return
    insts[pack.OpLhs] = (c, f) ->
        addr = memAddr(c, f)
        c.WriteReg(f.rt, signExt(c.ReadU16(addr)))
        return
    insts[pack.OpLhu] = (c, f) ->
        addr = memAddr(c, f)
        c.WriteReg(f.rt, c.ReadU16(addr))
        return
    insts[pack.OpLbs] = (c, f) ->
        addr = memAddr(c, f)
        c.WriteReg(f.rt, signExt8(c.ReadU8(addr)))
        return
    insts[pack.OpLbu] = (c, f) ->
        addr = memAddr(c, f)
        c.WriteReg(f.rt, c.ReadU8(addr))
        return
    insts[pack.OpSw] = (c, f) ->
        addr = memAddr(c, f)
        t = c.ReadReg(f.rt)
        c.WriteU32(addr, t)
        return
    insts[pack.OpSh] = (c, f) ->
        addr = memAddr(c, f)
        t = c.ReadReg(f.rt) & 0xffff
        c.WriteU16(addr, t)
        return
    insts[pack.OpSb] = (c, f) ->
        addr = memAddr(c, f)
        t = c.ReadReg(f.rt) & 0xff
        c.WriteU8(addr, t)
        return

    instList = makeInstList(insts, pack.Nop)

    opInst = (c, f) ->
        inst = f.inst
        op = (inst >> 26) & 0x3f
        f.rs = (inst >> 21) & 0x1f
        f.rt = (inst >> 16) & 0x1f
        f.im = inst & 0xffff
        f.ims = signExt(inst)
        
        instList[op](c, f)
        return

    pack.ALU = ->
        self = this
        self.fields = {}
        self.Inst = (c, inst) ->
            self.fields.inst = (inst >> 0)
            opInst(c, self.fields)
            return
        return

    pack.Rinst = (s, t, d, funct) ->
        ret = (s & 0x1f) << 21
        ret |= (t & 0x1f) << 16
        ret |= (d & 0x1f) << 11
        ret |= funct & 0x3f
        return ret

    pack.RinstShamt = (s, t, d, shamt, funct) ->
        ret = (s & 0x1f) << 21
        ret |= (t & 0x1f) << 16
        ret |= (d & 0x1f) << 11
        ret |= (shamt & 0x1f) << 6
        ret |= funct & 0x3f
        return ret

    pack.Iinst = (op, s, t, im) ->
        ret = (op & 0x3f) << 26
        ret |= (s & 0x1f) << 21
        ret |= (t & 0x1f) << 16
        ret |= im & 0xffff
        return ret

    pack.Jinst = (ad) ->
        ret = (pack.OpJ & 0x3f) << 26
        ret |= ad & 0x3ffffff
        return ret

    pack.InstStr = (i) ->
        if i == 0
            return "noop"

        op = (i >> 26) & 0x3f
        if op == pack.OpRinst
            rs = (i >> 21) & 0x1f
            rt = (i >> 16) & 0x1f
            rd = (i >> 11) & 0x1f
            shamt = (i >> 6) & 0x1f
            funct = i & 0x3f
            r3 = (op) -> (op+" $"+rd+", $"+rs+", $"+rt)
            r3r = (op) -> (op+" $"+rd+", $"+rt+", $"+rs)
            r3s = (op) -> (op+" $"+rd+", $"+rt+", "+shamt)

            switch funct
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
        else if op == pack.OpJ
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
