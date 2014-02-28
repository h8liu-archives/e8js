e8 = require("../e8")

inst = e8.inst
mem = e8.mem
vm = e8.vm

o = (b) ->
    if !b
        e = new Error("test failed")
        console.log(e.stack)
    return

c = vm.New()

dpage = mem.NewPage()
ipage = mem.NewPage()

str = "Hello, world.\n"
nstr = str.length
for i in [0..(nstr-1)]
    dpage.Write(i, str.charCodeAt(i))

ri = inst.Rinst
ii = inst.Iinst
ji = inst.Jinst

a = new mem.Align(ipage)

offset = 0
w = (i) ->
    a.WriteU32(offset, i)
    offset += 4

w(ri(0, 0, 1, inst.FnAdd))
w(ii(inst.OpLbu, 1, 2, 0x2000))
w(ii(inst.OpBeq, 2, 0, 0x0005))
w(ii(inst.OpLbu, 0, 3, 0x0005))
w(ii(inst.OpBne, 3, 0, 0xfffe))
w(ii(inst.OpSb, 0, 2, 0x0005))
w(ii(inst.OpAddi, 1, 1, 0x0001))
w(ji(-7))
w(ii(inst.OpSb, 0, 0, 0x0004))

c.Map(mem.PageStart(1), ipage)
c.Map(mem.PageStart(2), dpage)

o(c.ReadU32(mem.PageStart(1)) != 0)

c.SetPC(mem.PageStart(1))
used = c.Run(150)

o(used <= 150)
o(c.RIP())
