{ Plugin, $, path, Terminal, TermChar, TermCursor, TextBuffer, TextCursor, TextPoint, TextRegion, key } = Swim

TextPoint.prototype.distance = (target) ->
  Math.sqrt((@col - target.col) * (@col - target.col) + (@row - target.row) * (@row - target.row))

Swim.Editor = class Editor extends Terminal

  @::accessor 'textBuffer', -> @_textBuffer

  @::accessor 'textCursor', -> _.first(@_textCursors)

  @::accessor 'text',
    get: ->  @_textBuffer.text()
    set: (value) ->
      if @_textBuffer.text() != value
        @_textBuffer.setText(value)
        @setTextCursor()
        @_update()

  @::accessor 'document',
    get: ->  @_document
    set: (value) ->
      if @_document != value
        @_document = value
        @_update()

  @::accessor 'content',
    get: -> @text
    set: (value) ->
      @text = value

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

    _.extend @_options,
      acceptTabs: true
      tabToSpaces: true
      tabWidth: 2
      selFg: 0xFFFFFF
      selBg: 0x496D90

    if config?.options?
      _.extend(@_options, config.options)

    @_viewport = @rectangle(0, 0, @_size.x, @_size.y)

    @_document = if config?.document? then config.document else null

    @_textBuffer = new TextBuffer('')
    @_textCursors = []
    @setTextCursor()

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

    @_textBuffer.on 'reset', ( ->
      @diff()
      @emit 'editor:reset'
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

  fromTextPoint: (point) -> @point(point.col - @_viewport.x, point.row - @_viewport.y)

  pointToTextPoint: (pos) -> @textPoint(pos.y + @_viewport.y, pos.x + @_viewport.x)

  pointToTextIndex: (point) -> @textPointToTextIndex(@pointToTextPoint(point))

  textPointToTextIndex: (point) ->
    if point.row < @_textBuffer.lineCount()
      l = @_textBuffer.text(point.row)
    else
      l = null
    if l?
      return point.row * @_size.x + point.col
    else
      return -1

  indexToTextPoint: (index) ->
    x = 0
    y = 0
    for l in @_textBuffer.lines
      prevx = x
      x += l.length
      if x > index
        return @textPoint(y, index - x)
      y++
    return null

  indexToPoint: (index) -> @fromTextPoint(@indexToTextPoint(index))

  pixelToTextPoint: (pixel) -> @pointToTextPoint(@pixelToPos(pixel))

  viewLines: ->
    lines = []
    lc = @_textBuffer.lineCount()
    for y in [@_viewport.y..@_viewport.y + @_viewport.height]
      if y < lc
        lines.push @_textBuffer.lines[y].substr @_viewport.x, @_viewport.width
    return lines

  viewText: -> @viewLines().join("\n")

  textPoint: (row, col) ->
    if _.isNumber(row) and _.isNumber(col)
      return new TextPoint(@_textBuffer, row, col)
    else if row instanceof TextPoint
      return row.clone()
    else if _.isNumber(row)
      return @indexToTextPoint(row)
    else if row instanceof PIXI.Point
      return @pointToTextPoint(row)
    else if row instanceof TermCursor
      return @pointToTextPoint(row.pos)
    else if row instanceof TextCursor
      return @textCursorPoint(row).clone()
    else
      return new TextPoint(@_textBuffer, 0, 0)

  textRegion: (row, col, row2, col2) ->
    if _.isNumber(row) and _.isNumber(col) and _.isNumber(row2) and _.isNumber(col2)
      new TextRegion(@textPoint(row, col), @textPoint(row2, col2))
    else if _.isNumber(row) and _.isNumber(col)
      new TextRegion(@textPoint(row, col), @textPoint(row, col))
    else if row instanceof TextRegion
      new TextRegion(row.begin.clone(), row.end.clone())
    else if row instanceof TextPoint and col instanceof TextPoint
      new TextRegion(row.clone(), col.clone())
    else if row instanceof TextPoint
      new TextRegion(row.clone(), row.clone())
    else
      new TextRegion(@textPoint(), @textPoint())

  textRegionContains: (region, point, rect = false) ->
    r = region.ordered()
    if rect
      return point.row >= r.begin.row and point.row <= r.end.row and point.col >= r.begin.col and point.col <= r.end.col
    else
      point = @textPointToTextIndex(point)
      begin = @textPointToTextIndex(r.begin)
      end = @textPointToTextIndex(r.end) - 1
      return point >= begin and point <= end

  textCursorPoint: (c) ->
    if !c?
      c = @textCursor
    if c.region?
      return c.region.end
    else if c.point?
      return c.point
    else
      return @textPoint()

  textCursorRegion: (c) ->
    if !c?
      c = @textCursor
    if c.region?
      return c.region
    else if c.point?
      return @textRegion(c.point)
    else
      return @textRegion()

  setTextCursor: (cursor, point) ->
    if !(cursor instanceof TextCursor)
      point = cursor
      cursor = null
    if !cursor?
      cursor = @textCursor
    if !point?
      point = @textPoint()
    if @isValidTextPoint(point)
      if @_cursors.length == 0
        @addTextCursor(point)
      else
        cursor.moveTo(point)
    return @

  addTextCursor: (point) ->
    if @isValidTextPoint(point)
      tc = new TextCursor(@_textBuffer, point.row, point.col)
      @_textCursors.push tc

      c = @addCursor(point)
      c._textCursor = tc
      tc._termCursor = c

      @emit 'cursor:create', c

      tc.on 'move', ( ->
        @scrollInView()
        c.moveTo(@fromTextPoint(@textCursorPoint(tc)))
        @emit 'cursor:move', c
      ).bind @
    else
      tc = null

    return tc

  removeTextCursor: (cursor) ->
    if !(cursor instanceof TextCursor)
      point = cursor
      cursor = null
    if !cursor?
      cursor = @textCursor
    @emit 'cursor:destroy', cursor
    @removeCursor(cursor)
    _.remove(@_textCursors, cursor)
    return @

  moveTextCursor: (cursor, point) ->
    if !(cursor instanceof TextCursor)
      point = cursor
      cursor = null
    if !cursor?
      cursor = @textCursor
    if @isValidTextPoint(point)
      cursor.moveTo(point)
    return @

  selectTextCursor: (cursor, region) ->
    if !(cursor instanceof TextCursor)
      region = cursor
      cursor = null
    if !cursor?
      cursor = @textCursor
    if @isValidTextPoint(region.begin) and @isValidTextPoint(region.end)
      cursor.select(@textRegion(region))
    return @

  textCursorAt: (point, regionOnly = false) ->
    for c in @_textCursors
      if c.point? and c.point.col == point.col and c.point.row == point.row and !regionOnly
        return c
      else if c.region? and @textRegionContains(c.region, point)
        return c
    return null

  textCursorAtPixel: (pixel) -> @textCursorAt(@pixelToTextPoint(pixel))

  maxLineWidth: ->
    m = 0
    for l in @_textBuffer.lines
      if l.length > m
        m = l.length
    return m

  isValidTextPoint: (point) ->
    point.col >= 0 and point.row >= 0 and point.row < @_textBuffer.lineCount() and point.col <= @_textBuffer.text(point.row).length

  diff: ->
    pos = @point()
    point = @textPoint()
    vx = @_viewport.x
    vy = @_viewport.y
    vl = @viewLines()
    for y in [0...@_size.y]
      pos.y = y
      point.row = vy + y
      for x in [0...@_size.x]
        pos.x = x
        point.col = vx + x
        c = @charAt(pos)
        if c?
          tc = @textCursorAt(point, true)
          config =
            ch: c._ch
            fg: if tc? then @_options.selFg else @_fg
            bg: if tc? then @_options.selBg else @_bg
            font: c._font
          if y < vl.length and x < vl[y].length
            config.ch = vl[y][x]
          else
            config.ch = ' '
            config.fg = @_fg
            config.bg = @_bg
            config.font = @_font
          if c._ch != config.ch or c._fg != config.fg or c._bg != config.bg or c._font != config.font
            c.set(config)
    return @

  scrollBy: (pos) ->
    @_viewport.x += pos.x
    @_viewport.y += pos.y
    @diff()

  scrollTo: (pos) ->
    @scrollBy(@point(pos.x - @_viewport.x, pos.y - @_viewport.y))

  scrollInView: (point, hcenter = false, vcenter = false) ->
    if !point?
      point = @textCursorPoint()
    if @isValidTextPoint(point)
      pos = @point(point.col, point.row)
      vp = @_viewport.clone()
      if pos.x < vp.x
        vp.x = Math.max(0, pos.x)
      else if pos.x > vp.x + vp.width - 1
        vp.x = Math.min(@_textBuffer.text(pos.y).length - 1, pos.x - vp.width + 1)
      if pos.y < vp.y
        vp.y = Math.max(0, pos.y)
      else if pos.y > vp.y + vp.height - 1
        vp.y = Math.min(@_textBuffer.lineCount() - 1, pos.y - vp.height + 1)
      if vp.x != @_viewport.x or vp.y != @_viewport.y
        @scrollTo(vp)
    @diff()

  onDown: (e) ->
    tpt = @pixelToTextPoint(e.data.getLocalPosition(@))

    if !@_pressed?
      @_pressed = {}

    if !@_pressed.text?
      @_pressed.text = {}

    @_pressed.text.start = tpt
    @_pressed.text.pos = tpt
    @_pressed.text.distance = 0

    super e

    if @_clickCount == 1
      @setTextCursor(@textCursor, @_pressed.text.pos)

    @scrollInView()
    e.stopPropagation()

  onMove: (e) ->
    super e
    if @_pressed?
      tpt = @pixelToTextPoint(@_pressed.pixel.pos)
      @_pressed.text.pos = tpt
      @_pressed.text.distance = tpt.distance(@_pressed.text.start)
      tcp = @textCursorPoint(@textCursor)
      if tpt.row != tcp.row or tpt.col != tcp.col
        @selectTextCursor(@textCursor, @textRegion(@_pressed.text.start, tpt))
        @scrollInView()
      e.stopPropagation()

  onUp: (e) ->
    super e
    if @_pressed?
      e.stopPropagation()
    @scrollInView()

  onOver: (e) ->
    super e

  onOut: (e) ->
    super e

  onClick: (e) ->
    super e
    e.stopPropagation()

  onDblClick: (e) ->
    super e
    tpt = @_pressed.text.pos
    r = @_textBuffer.wordAt(tpt.row, tpt.col)
    @selectTextCursor(@textCursor, r)
    @scrollInView()
    e.stopPropagation()
