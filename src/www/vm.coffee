Terminal = (canvas) ->
    self = this

    dpr = window.devicePixelRatio
    ctx = canvas.getContext('2d')
    fontSize = 13
    fontSize *= dpr
    charHeight = fontSize
    lineHeight = charHeight + 2 * dpr
    ctx.font = '' + fontSize + 'px Consolas'
    charWidth = ctx.measureText('M').width

    ncol = 80
    nrow = 40
    col = 0
    row = 0

    width = ncol * charWidth / dpr
    height = nrow * lineHeight / dpr

    canvas.style.width = '' + width + 'px'
    canvas.style.height = '' + height + 'px'
    ctx.scale(dpr, dpr)
    canvas.width = width * dpr
    canvas.height = height * dpr

    ctx.font = '' + charHeight + 'px Consolas'
    ctx.fillStyle = '#000'
    ctx.textBaseline = 'bottom'

    this.incCursor = ->
        col += 1
        if col == ncol
            col = 0
            row += 1
        if row == nrow
            row = 0
        return

    this.putEndl = ->
        row += 1
        col = 0
        if row == nrow
            row = 0
        return

    this.putc = (c) ->
        if c == '\n'
            self.putEndl()
            return
        x = col * charWidth
        y = row * lineHeight + dpr
        ctx.clearRect(x, y, charWidth, charHeight)
        ctx.fillText(c, x, y + charHeight)
        self.incCursor()
        return

    this.clearCurLine = ->
        ctx.clearRect(0, row * lineHeight, charWidth * ncol, lineHeight)
        return

    this.Write = (b) ->
        self.putc(String.fromCharCode(b))
        return

    bound = (max, x) ->
        if x < 0
            return 0
        if x >= max
            return max - 1
        return x

    this.locate = (r, c) ->
        row = bound(nrow, r)
        col = bound(ncol, c)
        return
    
    this.print = (msg) ->
        chars = msg.split('')
        # self.clearCurLine()
        for c in chars
            self.putc(c)
        return

    this.println = (msg) ->
        self.print(msg)
        self.putEndl()

    return

Console = new Terminal($("canvas#console")[0])
Debugger = new Terminal($("canvas#debug")[0])

isSpecialKey = (code) ->
    if code >= 37 && code <= 40
        return true
    if code == 13 || code == 32
        return true
    return false

keydown = (e) ->
    code = event.which
    Debugger.locate(0, 0)
    Debugger.clearCurLine()
    Debugger.println('keycode = ' + code + '   ')
    if isSpecialKey(code)
        e.preventDefault()

$(window).keydown(keydown)

printRegs = (c) ->
    # Debugger.locate(2, 0)
    for i in [0..31]
        line = Math.floor(i / 4)
        col = i % 4
        Debugger.locate(2 + line, col * 15)
        v = c.ReadReg(i)
        if i < 10
            istr = '0' + i
        else
            istr = '' + i
        vstr = v.toString(16)
        while vstr.length < 8
            vstr = '0' + vstr
        Debugger.print(istr + ':' + vstr)
    return

test = ->
    inst = exports.inst
    vm = exports.vm
    mem = exports.mem

    c = vm.New()
    c.Stdout = Console

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

    # A hello world program
    w(ri(0, 0, 1, inst.FnAdd))
    w(ii(inst.OpLbu, 1, 2, 0x2000))
    w(ii(inst.OpBeq, 2, 0, 0x0005))
    w(ii(inst.OpLbu, 0, 3, 0x0009))
    w(ii(inst.OpBne, 3, 0, 0xfffe))
    w(ii(inst.OpSb, 0, 2, 0x0009))
    w(ii(inst.OpAddi, 1, 1, 0x0001))
    w(ji(-7))
    w(ii(inst.OpSb, 0, 0, 0x0008))

    c.Map(mem.PageStart(1), ipage)
    c.Map(mem.PageStart(2), dpage)
    
    # o(c.ReadU32(mem.PageStart(1)) != 0)

    c.SetPC(mem.PageStart(1))
    used = c.Run(150)
    printRegs(c)

    # o(used <= 150)
    # o(c.RIP())

# cons.print("this is the console.")
Debugger.println("this is the debugger.")

test()
