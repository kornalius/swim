{ Plugin, $, path, View, Terminal, TermChar, TermCursor, TextBuffer, TextCursor, TextPoint, TextRegion, key } = Swim

TextPoint.prototype.distance = (target) ->
  Math.sqrt((@col - target.col) * (@col - target.col) + (@row - target.row) * (@row - target.row))

Swim.TextView = class TextView extends View

  @::accessor 'textBuffer', -> @_textBuffer

  @::accessor 'textCursor', -> _.first(@_textCursors)

  @::accessor 'text',
    get: ->  @_textBuffer.text()
    set: (value) ->
      if @_textBuffer.text() != value
        @_textBuffer.setText(value)
        @_contentSize.x = @maxLineWidth() + 1
        @_contentSize.y = @_textBuffer.lineCount()
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

  constructor: (config) ->
    if !config?
      config = {}

    if !config.options?
      config.options = {}

    config.options = _.extend {},
      mouseMoveCursor: false
      acceptTabs: true
      tabToSpaces: true
      tabWidth: 2
      selFg: 0xFFFFFF
      selBg: 0x496D90
      scrollable:
        x: true
        y: true
    , config.options

    if !config.cursor?
      config.cursor = {}

    if !config.cursor.style?
      config.cursor.style = 'caret'

    if !config.cursor?.visible?
      config.cursor.visible = true

    super config

    @cursor.destroy()
    @_cursors = []

    @_document = if config?.document? then config.document else null

    @_textBuffer = new TextBuffer(@, '')
    @_textCursors = []
    @setTextCursor()

    @_textBuffer.on 'line:change', (row) =>
      @_contentSize.x = @maxLineWidth() + 1
      @_contentSize.y = @_textBuffer.lineCount()
      @scrollInView()
      @render()._update()

    @_textBuffer.on 'line:insert', (row) =>
      @_contentSize.x = @maxLineWidth() + 1
      @_contentSize.y = @_textBuffer.lineCount()
      @scrollInView()
      @render()._update()

    @_textBuffer.on 'line:delete', (row) =>
      @_contentSize.x = @maxLineWidth() + 1
      @_contentSize.y = @_textBuffer.lineCount()
      @scrollInView()
      @render()._update()

    @_textBuffer.on 'reset', =>
      @_contentSize.x = @maxLineWidth() + 1
      @_contentSize.y = @_textBuffer.lineCount()
      @scrollInView()
      @render()._update()

    @bindkey ['mod+c', 'mod+x', 'mod+v', 'mod+z', 'mod+shift+z'], (e) => e.preventDefault()

    @bindkey 'tab', (e) =>
      if @_options.acceptTabs
        if @_options.tabToSpaces
          t = " ".repeat(@_options.tabWidth)
        else
          t = String.fromCharCode(9)
        for c in @_textCursors
          c.insert(t)
        @scrollInView()
        @render()
        e.stopPropagation()
      else
        @focusNext()
        e.preventDefault()

    @bindkey 'shift+tab', (e) =>
      if @_options.acceptTabs
        @scrollInView()
        @render()
        e.stopPropagation()
      else
        @focusPrev()
        e.preventDefault()

    @bindkey 'backspace', (e) =>
      for c in @_textCursors
        c.deleteBack()
      e.stopPropagation()

    @bindkey ['ctrl+backspace', 'alt+backspace'], (e) =>
      for c in @_textCursors
        c.deleteWordBack()
      e.stopPropagation()

    @bindkey 'del', (e) =>
      for c in @_textCursors
        c.deleteForward()
      e.stopPropagation()

    @bindkey ['ctrl+del', 'alt+del'], (e) =>
      for c in @_textCursors
        c.deleteWordForward()
      e.stopPropagation()

    @bindkey ['space'].concat("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~!@#$%^&*()[]{}\\|\'\";:,<.>/?-=_+".split('')), (e) =>
      # console.log @, e
      for c in @_textCursors
        c.insert(String.fromCharCode(e.which))
      @scrollInView()
      @render()
      e.stopPropagation()

    @bindkey 'left', (e) =>
      for c in @_textCursors
        c.moveLeft()
      @scrollInView()
      @render()
      e.stopPropagation()

    @bindkey 'right', (e) =>
      for c in @_textCursors
        c.moveRight()
      @scrollInView()
      @render()
      e.stopPropagation()

    @bindkey 'up', (e) =>
      for c in @_textCursors
        c.moveUp()
      @scrollInView()
      @render()
      e.stopPropagation()

    @bindkey 'down', (e) =>
      for c in @_textCursors
        c.moveDown()
      @scrollInView()
      @render()
      e.stopPropagation()

    @bindkey ['ctrl+left', 'alt+left'], (e) =>
      for c in @_textCursors
        c.moveToPrevWord()
      @scrollInView()
      @render()
      e.stopPropagation()

    @bindkey ['ctrl+right', 'alt+right'], (e) =>
      for c in @_textCursors
        c.moveToNextWord()
      @scrollInView()
      @render()
      e.stopPropagation()

    @bindkey ['home', 'command+left'], (e) =>
      for c in @_textCursors
        c.moveToLineBegin()
      @scrollInView()
      @render()
      e.stopPropagation()

    @bindkey ['end', 'command+right'], (e) =>
      for c in @_textCursors
        c.moveToLineEnd()
      @scrollInView()
      @render()
      e.stopPropagation()

    @bindkey 'a b c', (e) =>
      console.log 'a b c pressed in sequence'
      e.stopPropagation()

    if config?.text?
      @textCursor.insert(config.text)

  getWidth: -> if @_size.x == -1 then @maxLineWidth() else @_size.x

  getHeight: -> if @_size.y == -1 then @viewLines().length else @_size.y

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
    if !@_textBuffer?
      return []
    lines = []
    lc = @_textBuffer.lineCount()
    for y in [@_viewport.y..@_viewport.y + @_viewport.height]
      if y < lc
        lines.push @_textBuffer.lines[y].substr @_viewport.x, @_viewport.width
    ee = Swim.CustomEvent target: @, lines: lines
    @modes_emit 'text.lines', ee
    return lines

  viewText: -> @viewLines().join("\n")

  maxLineWidth: ->
    m = 0
    for l in @_textBuffer.lines
      if l.length > m
        m = l.length
    ee = Swim.CustomEvent target: @, width: m
    @modes_emit 'text.maxLineWidth', ee
    if !ee.defaultPrevented
      m = ee.detail.width
    return m

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
        cursor = @addTextCursor(point)
      else
        cursor.moveTo(point)
    return cursor

  addTextCursor: (point) ->
    if @isValidTextPoint(point)
      cursor = new TextCursor(@_textBuffer, point.row, point.col)
      @_textCursors.push cursor

      c = @addCursor(point)
      c._textCursor = cursor
      cursor._termCursor = c

      cursor.on 'move', =>
        ee = Swim.CustomEvent target: cursor
        cursor.emit 'text.cursor.move', ee
        @scrollInView()
        c.moveTo(@fromTextPoint(@textCursorPoint(cursor)))
        @render()._update()

      cursor.attached()
    else
      cursor = null

    return cursor

  removeTextCursor: (cursor) ->
    if !(cursor instanceof TextCursor)
      point = cursor
      cursor = null
    if !cursor?
      cursor = @textCursor
    cursor.detached()
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
    if !@_textCursors?
      return null
    for c in @_textCursors
      if c.point? and c.point.col == point.col and c.point.row == point.row and !regionOnly
        return c
      else if c.region? and @textRegionContains(c.region, point)
        return c
    return null

  textCursorAtPixel: (pixel) -> @textCursorAt(@pixelToTextPoint(pixel))

  isValidTextPoint: (point) -> @isValidViewPos(@point(point.col, point.row))

  render_char: (e) =>
    d = e.detail
    if @textCursorAt(@textPoint(d.viewpos.y, d.viewpos.x), true)?
      d.to_apply.fg = @_options.selFg
      d.to_apply.bg = @_options.selBg
    else
      d.to_apply.fg = @_fg
      d.to_apply.bg = @_bg

  scrollBy: (pos) ->
    super pos
    ee = Swim.CustomEvent target: @, pos: pos
    @modes_emit 'text.scrollby', ee
    if !ee.defaultPrevented
      for tc in @_textCursors
        tc._termCursor.moveTo(@fromTextPoint(@textCursorPoint(tc)))
      @render()._update()
    return @

  scrollInView: (point, hcenter = false, vcenter = false) ->
    if !point?
      point = @textCursorPoint()
    if !point?
      point = @textPoint()
    super @point(point.col, point.row), hcenter, vcenter

  onDown: (e) =>
    tpt = @pixelToTextPoint(e.data.getLocalPosition(@))

    if !@_pressed?
      @_pressed = {}

    if !@_pressed.text?
      @_pressed.text = {}

    @_pressed.text.start = tpt.clone()
    @_pressed.text.pos = tpt
    @_pressed.text.distance = 0

    super e

    if !e.defaultPrevented
      if @_clickCount == 1
        @setTextCursor(@textCursor, @_pressed.text.pos)

      @scrollInView()
      @render()._update()

    e.stopPropagation()

  onMove: (e) =>
    super e

    if !e.defaultPrevented and @_pressed?
      tpt = @pixelToTextPoint(@_pressed.pixel.pos)
      @_pressed.text.pos = tpt
      @_pressed.text.distance = tpt.distance(@_pressed.text.start)
      tcp = @textCursorPoint(@textCursor)

      if tpt.row != tcp.row or tpt.col != tcp.col
        @selectTextCursor(@textCursor, @textRegion(@_pressed.text.start, tpt))
        @scrollInView()
        @render()._update()

    e.stopPropagation()

  onUp: (e) =>
    super e

    if !e.defaultPrevented and @_pressed?
      @scrollInView()
      @render()._update()

    e.stopPropagation()

  onDblClick: (e) =>
    super e

    if !e.defaultPrevented and @_pressed?
      tpt = @_pressed.text.pos
      r = @_textBuffer.wordAt(tpt.row, tpt.col)
      @selectTextCursor(@textCursor, r)
      @scrollInView()
      @render()._update()

    e.stopPropagation()
