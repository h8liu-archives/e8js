exports.vm = new (->
    pack = this

    inst = exports.inst
    mem = exports.mem
    align = exports.align
    
    pack.Registers = ->
        self = this

        regs = new Uint32Array(inst.Nreg)
        fregs = new Float64Array(inst.Nfreg)
        
        self.ReadReg = (a) -> regs[a]
        self.ReadFreg = (a) -> fregs[a]

        self.WriteReg = (a, v) ->
            v = v >> 0
            if a == 0
                # do nothing
            else if a == inst.RegPC
                regs[a] = align.U32(v)
            else
                regs[a] = v
            return
        
        self.WriteFreg = (a, v) ->
            fregs[a] = v
            return

        self.IncPC = (a, v) ->
            ret = self.ReadReg(inst.RegPC)
            self.WriteReg(inst.RegPC, ret + 4)
            return ret
        
        self.PrintTo = (logger) ->
            for i in [0..(inst.Nreg-1)]
                v = self.ReadReg(i)
                logger.log('$'+i+" = "+v.toString(16))

        return
    
    pack.SysPage = ->
        self = this
        self.AddrError = false
        self.Halt = false
        self.HaltValue = 0
        
        cap = 32
        stdin = []
        stdout = []

        self.Halted = -> self.Halt
        self.ClearError = ->
            self.AddrError = false
            self.Halt = false
            return
        
        addrError = ->
            self.AddrError = true
            self.Halt = true
            self.HaltValue = 0xff

        self.Read = (offset) ->
            if offset < 8
                addrError()
                return 0

            switch offset
                when 9
                    if stdout.length < cap
                        return 0
                    return 1
                when 10
                    if stdin.length > 0
                        return 0
                    return 1
                when 11
                    if stdin.length > 0
                        return stdin.shift()
                    return 0
            return 0

        self.Write = (offset, b) ->
            b = b & 0xff
            if offset < 8
                addrError()
                return

            switch offset
                when 8
                    self.Halt = true
                    self.HaltValue = b
                when 9
                    if stdout.length < cap
                        stdout.push(b)
            return

        self.FlushStdout = (w) ->
            while stdout.length > 0
                w.Write(stdout.shift())
            return

        return

    pack.Console = ->
        self = this
        
        self.buf = ""
        self.Write = (b) ->
            if b == 10
                console.log(self.buf)
                self.buf = ""
            else
                self.buf += String.fromCharCode(b)
            return

        self.Flush = ->
            if self.buf.length > 0
                console.log(self.buf)
                self.buf = ""
            return

        return

    pack.Core = ->
        self = this

        regs = new pack.Registers()
        memory = new mem.Memory()
        alu = new inst.ALU()
        sys = new pack.SysPage()
        memory.Map(0, sys)

        self.Stdout = new pack.Console()
        
        self.ReadReg = regs.ReadReg
        self.ReadFreg = regs.ReadFreg
        self.WriteReg = regs.WriteReg
        self.WriteFreg = regs.WriteFreg
        self.IncPC = regs.IncPC
        self.PrintTo = regs.PrintTo
        
        self.Get = memory.Get
        self.Valid = memory.Valid
        self.Align = memory.Align
        self.WriteU8 = memory.WriteU8
        self.WriteU16 = memory.WriteU16
        self.WriteU32 = memory.WriteU32
        self.ReadU8 = memory.ReadU8
        self.ReadU16 = memory.ReadU16
        self.ReadU32 = memory.ReadU32
        self.Map = memory.Map
        self.Unmap = memory.Unmap

        self.SetPC = (pc) ->
            regs.WriteReg(inst.RegPC, pc)
            return
        
        self.Run = (n) ->
            i = 0
            while i < n
                self.Step()
                i = i + 1
                if sys.Halted()
                    break
            return i

        self.Step = ->
            sys.ClearError()
            pc = regs.IncPC()
            i = memory.ReadU32(pc)
            # console.log(pc, i, inst.InstStr(i), regs.ReadReg(2))
            alu.Inst(self, i)
            sys.FlushStdout(self.Stdout)
                
        self.Halted = sys.Halted
        self.AddrError = -> sys.AddrError
        self.HaltValue = -> sys.HaltValue
        self.RIP = ->
            self.Halted() && self.HaltValue() == 0 && !self.AddrError()

        return

    pack.New = -> new pack.Core()
    
    return
)()
