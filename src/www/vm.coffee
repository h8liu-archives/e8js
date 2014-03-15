Terminal = (canvas) ->
    thiz = this

    dpr = window.devicePixelRatio
    ctx = canvas.getContext('2d')
    fontSize = 13
    charHeight = fontSize * dpr
    ctx.font = '' + charHeight + 'px Consolas'
    charWidth = ctx.measureText('M').width

    ncol = 80
    nrow = 50
    col = 0
    row = 0

    width = ncol * charWidth / dpr
    height = nrow * charHeight / dpr

    canvas.style.width = '' + width + 'px'
    canvas.style.height = '' + height + 'px'
    ctx.scale(dpr, dpr)
    canvas.width = width * dpr
    canvas.height = height * dpr

    this.putc = (c) ->
        x = col * charWidth
        y = row * charHeight
        ctx.clearRect(x, y, charWidth, charHeight)
        ctx.fillText(c, x, y + charHeight)
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
        ctx.font = '' + charHeight + 'px Consolas'
        ctx.fillStyle = '#000'
        row = 0
        col = 0
        for c in chars
            thiz.putc(c)
            col += 1
        return
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
    Console.print('keycode = ' + code + '   ')
    if isSpecialKey(e)
        e.preventDefault()

$(window).keydown(keydown)

# cons.print("this is the console.")
Debugger.print("this is the debugger.")

