{ Plugin, $, path, Terminal, TermChar, TermCursor, TextBuffer, TextCursor, key } = Swim

Swim.TextEdit = class TextEdit extends Terminal

  @::accessor 'textBuffer', -> @_textBuffer

  @::accessor 'textCursor', -> _.first(@_textCursors)

  @::accessor 'text',
    get: ->  @_textBuffer.text()
    set: (value) ->
      if @_textBuffer.text() != value
        @_textBuffer.setText(value)
        @setTextCursor(new PIXI.Point())
        @_update()

  @::accessor 'options', ->  _.first(@_options)

  constructor: (config) ->
    if !config?
      config = {}
    if !config.cursor?
      config.cursor = {}
    if !config.cursor.style?
      config.cursor.style = 'caret'

    super config
    @cursor.destroy()
    @_cursors = []

    @_tabIndex = 0

    @_options =
      acceptTabs: true
      tabToSpaces: true
      tabWidth: 2

    if config?.options?
      _.extend(@_options, config.options)

    @_viewport = new PIXI.Rectangle(0, 0, @_size.x, @_size.y)

    @_textBuffer = new TextBuffer('')
    @_textCursors = []
    @setTextCursor(new PIXI.Point(0, 0))

    @_textBuffer.on 'line:change', ((row) ->
      @diff()
      @_update()
    ).bind @

    @_textBuffer.on 'line:insert', ((row) ->
      @diff()
      @_update()
    ).bind @

    @_textBuffer.on 'line:delete', ((row) ->
      @diff()
      @_update()
    ).bind @

    @_textBuffer.on 'reset', ((row) ->
      @diff()
      @_update()
    ).bind @

    @bindkey ['mod+c', 'mod+x', 'mod+v', 'mod+z', 'mod+shift+z'], (e) -> e.preventDefault()

    @bindkey 'tab', (e) ->
      if @_options.acceptTabs
        if @_options.tabToSpaces
          t = " ".repeat(@_options.tabWidth)
        else
          t = String.fromCharCode(9)
        for c in @_textCursors
          c.insert(t)
        @scrollInView()
        e.stopPropagation()
      else
        @focusNext()
        e.preventDefault()

    @bindkey 'shift+tab', (e) ->
      if @_options.acceptTabs
        @scrollInView()
        e.stopPropagation()
      else
        @focusPrev()
        e.preventDefault()

    @bindkey 'backspace', (e) ->
      for c in @_textCursors
        c.deleteBack()
      e.stopPropagation()

    @bindkey ['ctrl+backspace', 'alt+backspace'], (e) ->
      for c in @_textCursors
        c.deleteWordBack()
      e.stopPropagation()

    @bindkey 'del', (e) ->
      for c in @_textCursors
        c.deleteForward()
      e.stopPropagation()

    @bindkey ['ctrl+del', 'alt+del'], (e) ->
      for c in @_textCursors
        c.deleteWordForward()
      e.stopPropagation()

    @bindkey ['space'].concat("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~!@#$%^&*()[]{}\\|\'\";:,<.>/?-=_+".split('')), (e) ->
      # console.log @, e
      for c in @_textCursors
        c.insert(String.fromCharCode(e.which))
      @scrollInView()
      e.stopPropagation()

    @bindkey 'left', (e) ->
      for c in @_textCursors
        c.moveLeft()
      @scrollInView()
      e.stopPropagation()

    @bindkey 'right', (e) ->
      for c in @_textCursors
        c.moveRight()
      @scrollInView()
      e.stopPropagation()

    @bindkey 'up', (e) ->
      for c in @_textCursors
        c.moveUp()
      @scrollInView()
      e.stopPropagation()

    @bindkey 'down', (e) ->
      for c in @_textCursors
        c.moveDown()
      @scrollInView()
      e.stopPropagation()

    @bindkey ['ctrl+left', 'alt+left'], (e) ->
      for c in @_textCursors
        c.moveToPrevWord()
      @scrollInView()
      e.stopPropagation()

    @bindkey ['ctrl+right', 'alt+right'], (e) ->
      for c in @_textCursors
        c.moveToNextWord()
      @scrollInView()
      e.stopPropagation()

    @bindkey ['home', 'command+left'], (e) ->
      for c in @_textCursors
        c.moveToLineBegin()
      @scrollInView()
      e.stopPropagation()

    @bindkey ['end', 'command+right'], (e) ->
      for c in @_textCursors
        c.moveToLineEnd()
      @scrollInView()
      e.stopPropagation()

    @bindkey 'a b c', (e) ->
      console.log 'a b c pressed in sequence'
      e.stopPropagation()

    if config?.text?
      @textCursor.insert(config.text)

  fromTextPos: (pos) -> new PIXI.Point(pos.x - @_viewport.x, pos.y - @_viewport.y)

  toTextPos: (pos) -> new PIXI.Point(pos.x + @_viewport.x, pos.y + @_viewport.y)

  posToTextIndex: (pos) -> @textPosToTextIndex(@toTextPos(pos))

  textPosToTextIndex: (pos) ->
    if pos.y < @_textBuffer.lineCount()
      l = @_textBuffer.text(pos.y)
    else
      l = null
    if l?
      p = @fromTextPos(pos)
      p.y * @_size.x + p.x
    else
      return -1

  textIndexToTextPos: (index) ->
    x = 0
    y = 0
    for l in @_textBuffer.lines
      prevx = x
      x += l.length
      if x > index
        return new PIXI.Point(index - x, y)
      y++
    return null

  textIndexToPos: (index) -> @fromTextPos(@textIndexToTextPos(index))

  pixelToTextPos: (px) -> @toTextPos(@pixelToPos(px))

  viewLines: ->
    lines = []
    for y in [@_viewport.y..@_viewport.y + @_viewport.height]
      if y < @_textBuffer.lineCount()
        lines.push @_textBuffer.lines[y].substr @_viewport.x, @_viewport.width
    return lines

  viewText: ->
    @viewLines().join("\n")

  setTextCursor: (pos) ->
    if @_cursors.length == 0
      @addTextCursor(pos)
    else
      @cursor.moveTo(@fromTextPos(pos))
      @textCursor.moveTo(pos.y, pos.x)
    return @

  addTextCursor: (pos) ->
    tc = new TextCursor(@_textBuffer, pos.x, pos.y)
    @_textCursors.push tc

    c = @addCursor(@fromTextPos(pos))
    c._textCursor = tc
    tc._termCursor = c

    tc.on 'move', ( ->
      @scrollInView()
      p = @fromTextPos(new PIXI.Point(tc.point.col, tc.point.row))
      # console.log "TextCursor move", tc.point.col, tc.point.row, "fromTextPos", p.toString(), @_viewport.toString()
      c.moveTo(p)
    ).bind @

    return tc

  removeTextCursor: (pos) ->
    if pos instanceof PIXI.Point
      tc = @cursorAt(@fromTextPos(pos))
    else if pos instanceof TermCursor
      tc = pos._textCursor
    else if pos instanceof TextCursor
      tc = pos
    else
      tc = null
    if tc?
      @removeCursor(tc._termCursor)
      _.remove(@_textCursors, tc)
    return @

  moveTextCursor: (pos, newpos) ->
    if pos instanceof PIXI.Point
      tc = @cursorAt(@fromTextPos(pos))
    else if pos instanceof TermCursor
      tc = pos._textCursor
    else if pos instanceof TextCursor
      tc = pos
    else
      tc = @textCursor
    if tc?
      tc.moveTo(newpos.x, newpos.y)
    return @

  textCursorAt: (pos) ->
    for c in @_textCursors
      if c.point.col == pos.x and c.point.row == pos.y
        return c
    return null

  textCursorAtPixel: (p) -> @textCursorAt(@pixelToTextPos(p))

  maxLineWidth: ->
    m = 0
    for l in @_textBuffer.lines
      if l.length > m
        m = l.length
    return m

  isValidTextPos: (pos) ->
    pos.x >= 0 and pos.y >= 0 and pos.y < @_textBuffer.lineCount() and pos.x <= @_textBuffer.text(pos.y).length

  scrollBy: (pos) ->
    @_viewport.x += pos.x
    @_viewport.y += pos.y
    @diff()

  scrollTo: (pos) ->
    @scrollBy(new PIXI.Point(pos.x - @_viewport.x, pos.y - @_viewport.y))

  diff: ->
    pos = new PIXI.Point()
    vl = @viewLines()
    for y in [0...@_size.y]
      pos.y = y
      for x in [0...@_size.x]
        pos.x = x
        if y < vl.length and x < vl[y].length
          c = @setChar(pos, { ch: vl[y][x] })
        else
          @eraseAt(pos)
    return @

  textCursorPos: (cursor) ->
    if !cursor?
      cursor = @textCursor
    new PIXI.Point(cursor.point.col, cursor.point.row)

  scrollInView: (pos, hcenter = false, vcenter = false) ->
    if !pos?
      if @_textCursors.length > 1
        return
      pos = @textCursorPos()

    if @isValidTextPos(pos)
      p = pos.clone()
      vp = @_viewport.clone()

      if p.x < vp.x
        vp.x = Math.max(0, p.x)
      else if p.x > vp.x + vp.width - 1
        vp.x = Math.min(@_textBuffer.text(p.y).length - 1, p.x - vp.width + 1)

      if p.y < vp.y
        vp.y = Math.max(0, p.y)
      else if p.y > vp.y + vp.height - 1
        vp.y = Math.min(@_textBuffer.lineCount() - 1, p.y - vp.height + 1)

      if vp.x != @_viewport.x or vp.y != @_viewport.y
        @scrollTo(vp)

    return @

  onDown: (e) ->
    t = e.target
    p = t.pixelToTextPos(e.data.getLocalPosition(t))
    t.setTextCursor(p)
    super e
    e.stopPropagation()

  onMove: (e) ->
    t = e.target
    if t._pressed
      p = t.pixelToTextPos(e.data.getLocalPosition(t))
      t.setTextCursor(p)
    super e
    e.stopPropagation()

  onUp: (e) ->
    t = e.target
    if t._pressed
      p = t.pixelToTextPos(e.data.getLocalPosition(t))
      t.setTextCursor(p)
      @scrollInView()
    super e
    e.stopPropagation()

