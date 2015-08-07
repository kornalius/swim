{ Plugin, PIXI, PropertyAccessors } = Swim

Swim.terminals = []

Swim.clickDistance = 8
Swim.dblclickTime = 350

Swim.Terminal = class Terminal extends PIXI.Container

  PropertyAccessors.includeInto(@)

  @::accessor 'fg',
    get: -> @_fg
    set: (value) ->
      if @_fg != value
        @_fg = value

  @::accessor 'bg',
    get: -> @_bg
    set: (value) ->
      if @_bg != value
        @_bg = value

  @::accessor 'font',
    get: -> @_font
    set: (value) ->
      if @_font.name != value.name or @_font.size != value.size or @_font.bold != value.bold or @_font.italic != value.italic or @_font.underline != value.underline
        @_font = value

  @::accessor 'rect',
    get: -> @rectangle(@_rect.x, @_rect.y, @_rect.width, @_rect.height)
    set: (value) ->
      if @_rect.x != value.x or @_rect.y != value.y or @_rect.width != value.width or @_rect.height != value.height
        @_pos.x = Math.trunc(value.x / @_charWidth)
        @_pos.y = Math.trunc(value.y / @_charHeight)
        @_size.x = Math.trunc(value.width / @_charWidth)
        @_size.y = Math.trunc(value.height / @_charHeight)
        @position = @positionInPixels()
        @_rect = @rectangle(@position.x, @position.y, @widthInPixels(), @heightInPixels())
        @_update()

  @::accessor 'padding',
    get: -> @_padding
    set: (value) ->
      if @_padding != value
        @_padding = value
        @position = @positionInPixels()
        @_rect = @rectangle(@position.x, @position.y, @widthInPixels(), @heightInPixels())
        @_update()

  @::accessor 'pos',
    get: -> @_pos
    set: (value) ->
      if @_pos.x != value.x or @_pos.y != value.y
        @_pos.x = value.x
        @_pos.y = value.y
        @position = @positionInPixels()
        @_update()

  @::accessor 'size',
    get: -> @_size
    set: (value) ->
      if @_size.x != value.x or @_size.y != value.y
        @_size = value.clone()
        @_rect.width = @widthInPixels()
        @_rect.height = @heightInPixels()
        @_update()

  @::accessor 'charWidth',
    get: -> @_charWidth
    set: (value) ->
      if @_charWidth != value
        @_charWidth = value
        @_rect = @rectangle(@position.x, @position.y, @widthInPixels(), @heightInPixels())
        @_update()

  @::accessor 'charHeight',
    get: -> @_charHeight
    set: (value) ->
      if @_charHeight != value
        @_charHeight = value
        @_rect = @rectangle(@position.x, @position.y, @widthInPixels(), @heightInPixels())
        @_update()

  @::accessor 'rows',
    get: -> @_rows
    set: (value) ->
      if !_.deepEqual(@_rows, value)
        @_rows = value
        @_update()

  @::accessor 'modes',
    get: -> @_modes
    set: (value) ->
      if !_.deepEqual(@_modes, value)
        @_modes = value
        @_update()

  @::accessor 'cursors',
    get: -> @_cursors
    set: (value) ->
      @_cursors = value
      for c in @_cursors
        c._update()

  @::accessor 'cursor', -> _.last(@_cursors)

  @::accessor 'cursorConfig',
    get: -> @_cursorConfig
    set: (value) ->
      if _.equal(@_cursorConfig, value)
        @_cursorConfig = value
        @_update()

  @::accessor 'palette',
    get: -> @_palette
    set: (value) ->
      if !_.deepEqual(@_palette, value)
        @_palette = value
        @_update()

  @::accessor 'focused',
    get: -> @_focused
    set: (value) ->
      if @_focused != value
        @_focused = value
        @_update()

  @::accessor 'options',
    get: -> @_options
    set: (value) ->
      if @_options != value
        @_options = value
        @_update()

  @::accessor 'z',
    get: -> @_z
    set: (value) ->
      if @_z != value
        @_z = value
        p = @parent
        if p? and p instanceof Terminal
          p._reorder()

  @::accessor 'tabIndex',
    get: -> @_tabIndex
    set: (value) ->
      if @_tabIndex != value
        @_tabIndex = value
        if @focused and value == -1
          @focusPrev()

  @::accessor 'content',
    get: ->
      lines = []
      for r in @_rows
        line = ""
        for c in r
          line += c._ch if c?
        lines.push line
      return lines.join("\n")
    set: (value) ->
      if @content != value
        @cls.write(value)
        @_update()

  @::accessor 'foreground', -> @fg = @_palette.fg; @
  @::accessor 'background', -> @fg = @_palette.bg; @
  @::accessor 'black',      -> @fg = @_palette.black; @
  @::accessor 'red',        -> @fg = @_palette.red; @
  @::accessor 'green',      -> @fg = @_palette.green; @
  @::accessor 'yellow',     -> @fg = @_palette.yellow; @
  @::accessor 'blue',       -> @fg = @_palette.blue; @
  @::accessor 'magenta',    -> @fg = @_palette.magenta; @
  @::accessor 'cyan',       -> @fg = @_palette.cyan; @
  @::accessor 'white',      -> @fg = @_palette.white; @
  @::accessor 'brblack',    -> @fg = @_palette.brblack; @
  @::accessor 'brred',      -> @fg = @_palette.brred; @
  @::accessor 'brgreen',    -> @fg = @_palette.brgreen; @
  @::accessor 'bryellow',   -> @fg = @_palette.bryellow; @
  @::accessor 'brblue',     -> @fg = @_palette.brblue; @
  @::accessor 'brmagenta',  -> @fg = @_palette.brmagenta; @
  @::accessor 'brcyan',     -> @fg = @_palette.brcyan; @
  @::accessor 'brwhite',    -> @fg = @_palette.brwhite; @

  @::accessor 'bgblack',      -> @bg = @_palette.black; @
  @::accessor 'bgred',        -> @bg = @_palette.red; @
  @::accessor 'bggreen',      -> @bg = @_palette.green; @
  @::accessor 'bgyellow',     -> @bg = @_palette.yellow; @
  @::accessor 'bgblue',       -> @bg = @_palette.blue; @
  @::accessor 'bgmagenta',    -> @bg = @_palette.magenta; @
  @::accessor 'bgcyan',       -> @bg = @_palette.cyan; @
  @::accessor 'bgwhite',      -> @bg = @_palette.white; @
  @::accessor 'bgbrblack',    -> @bg = @_palette.brblack; @
  @::accessor 'bgbrred',      -> @bg = @_palette.brred; @
  @::accessor 'bgbrgreen',    -> @bg = @_palette.brgreen; @
  @::accessor 'bgbryellow',   -> @bg = @_palette.bryellow; @
  @::accessor 'bgbrblue',     -> @bg = @_palette.brblue; @
  @::accessor 'bgbrmagenta',  -> @bg = @_palette.brmagenta; @
  @::accessor 'bgbrcyan',     -> @bg = @_palette.brcyan; @
  @::accessor 'bgbrwhite',    -> @bg = @_palette.brwhite; @

  bgcol: (value) -> @bg = value; @
  fgcol: (value) -> @fg = value; @

  @::accessor 'reset', -> @_fg = @_palette.fg; @_bg = @_palette.bg; @_update(); @

  @::accessor 'bol',    -> c.bol() for c in @_cursors; @
  @::accessor 'eol',    -> c.eol() for c in @_cursors; @
  @::accessor 'left',   -> c.left() for c in @_cursors; @
  @::accessor 'right',  -> c.right() for c in @_cursors; @
  @::accessor 'up',     -> c.up() for c in @_cursors; @
  @::accessor 'down',   -> c.down() for c in @_cursors; @
  @::accessor 'cr',     -> c.cr() for c in @_cursors; @
  @::accessor 'home',   -> c.home() for c in @_cursors; @
  @::accessor 'end',    -> c.end() for c in @_cursors; @
  @::accessor 'cls',    -> @erase().home

  constructor: (config) ->
    super

    @_id = _.uniqueId()

    @_z = 0
    @_focused = false
    @_prevBlink = Date.now()
    @_tabIndex = -1

    # @name = "TerminalContainer"

    # RGBFilter = require('./shaders/rgb/rgb.coffee')
    # PIXI.BlurFilter
    # f = new RGBFilter()

    # PIXI.ticker.shared.add (time) ->
      # f.time = time

    @_rows = []
    @_modes = []

    @_palette = config?.palette or Swim.palettes.default
    @_pos = config?.pos or @point()
    @_size = config?.size or @point(80, 24)
    @_fg = config?.fg or @_palette.fg
    @_bg = config?.bg or @_palette.bg
    if config?.font
      @_font = Swim.getFont(config.font)
    else
      @_font = Swim.getFont(name: 'Lucida Console', size: 12)
    @_charWidth = config?.charWidth or @_font.width
    @_charHeight = config?.charHeight or @_font.height

    @_options =
      dblclickTime: 500
      clickDistance: 1

    if config?.options?
      _.extend(@_options, config.options)

    @_cursorConfig =
      width: @_charWidth
      height: @_charHeight
      offset: @point()
      wrap: true
      blink: 500
      type: 'block'

    if config?.cursor?.width?
      @_cursorConfig.width = config.cursor.width
    if config?.cursor?.height?
      @_cursorConfig.height = config.cursor.height
    if config?.cursor?.offset?
      @_cursorConfig.offset = config.cursor.offset
    if config?.cursor?.wrap?
      @_cursorConfig.wrap = config.cursor.wrap
    if config?.cursor?.blink?
      @_cursorConfig.blink = config.cursor.blink
    if config?.cursor?.type?
      @_cursorConfig.type = config.cursor.type

    if @_cursorConfig.type == 'block'
      @_cursorConfig.width = @_charWidth
      @_cursorConfig.height = @_charHeight
      @_cursorConfig.offset = @point()

    else if @_cursorConfig.type == 'underline'
      @_cursorConfig.offset = @point(0, @_cursorConfig.height - 4)
      @_cursorConfig.height = 4

    else if @_cursorConfig.type == 'caret'
      @_cursorConfig.offset = @point(0, -1)
      @_cursorConfig.height += 2
      @_cursorConfig.width = 2

    @_padding = config?.padding or 0
    @_border = config?.border or null
    @_viewport = config?.viewport or null

    @interactive = true

    @position = @positionInPixels()
    @_rect = @rectangle(@position.x, @position.y, @widthInPixels(), @heightInPixels())

    # @filters = [f]

    @_clickCount = 0
    @_dblClickTimer = null

    @on 'mousedown', @onDown.bind @
    @on 'rightdown', @onDown.bind @
    @on 'mousemove', @onMove.bind @
    @on 'mouseup', @onUp.bind @
    @on 'rightup', @onUp.bind @
    @on 'mouseout', @onOut.bind @
    @on 'mouseover', @onOver.bind @

    @on 'touchstart', @onDown.bind @
    @on 'touchmove', @onMove.bind @
    @on 'touchup', @onUp.bind @

    @on 'click', @onClick.bind @
    @on 'dblclick', @onDblClick.bind @

    @on 'added', ((c) ->
      if @ instanceof Terminal
        @position = @positionInPixels()
        @_rect = @rectangle(@position.x, @position.y, @widthInPixels(), @heightInPixels())
    ).bind(@)

    @_backLayer = new PIXI.Graphics()
    @_backLayer.cacheAsBitmap = true
    @addChild(@_backLayer)

    @_backTextLayer = new PIXI.Container()
    @_backTextLayer.cacheAsBitmap = true
    @addChild(@_backTextLayer)

    @_textLayer = new PIXI.Container()
    @_textLayer.cacheAsBitmap = true
    @addChild(@_textLayer)

    if @_border?
      @_borderLayer = new PIXI.Graphics()
      @_borderLayer.cacheAsBitmap = true
      @addChild(@_borderLayer)

    @_cursors = [new Swim.TermCursor(@, @_cursorConfig)]

    @_tmpPt = @point()
    @_tmpPt2 = @point()
    @_tmpRect = @rectangle()

    Swim.terminals.push @

    @clear()

    @_cursorsTick = ((time) ->
      if Date.now() - @_prevBlink >= @_cursorConfig.blink
        if @focused
          for c in @_cursors
            if c._visible
              c._state.visible = !c._state.visible
              c._update()
        else
          for c in @_cursors
            if c._state.visible
              c._state.visible = false
              c._update()
        @_prevBlink = Date.now()
    ).bind(@)

    PIXI.ticker.shared.add @_cursorsTick

  destroy: ->
    console.log "Destroying #{@toString()}..."

    PIXI.ticker.shared.remove(@_cursorsTick)

    for c in @_cursors
      c.destroy()
    @_cursors = []

    for c in @_chars()
      c.destroy()

    @_rows = []
    @_font = null

    if @_backSprite?
      @_backSprite.destroy()

    @_backLayer.removeChildren()
    @_backLayer.parent.removeChild(@_backLayer)
    @_backLayer = null

    @_textLayer.removeChildren()
    @_textLayer.parent.removeChild(@_textLayer)
    @_textLayer = null

    @_backTextLayer.removeChildren()
    @_backTextLayer.parent.removeChild(@_backTextLayer)
    @_backTextLayer = null

    if @_borderLayer?
      @_borderLayer.removeChildren()
      @_borderLayer.parent.removeChild(@_borderLayer)
      @_borderLayer = null

    @_rect = null

    _.remove(Swim.terminals, @)

    super

  addTerminal: (t) ->
    r = @addChild(t)
    @_reorder()
    return r

  removeTerminal: (t) ->
    r = @removeChild(t)
    @_reorder()
    return r

  clear: ->
    for c in @_cursors
      c.destroy()
    @_cursors = [new Swim.TermCursor(@, @_cursorConfig)]

    for c in @_chars()
      c.destroy()

    @_rows = []
    for y in [0...@_size.y]
      l = []
      for x in [0...@_size.x]
        l.push(null)
      @_rows.push(l)

    @_backTextLayer.removeChildren()
    @_textLayer.removeChildren()

    @_updateBackSprite()
    @_updateBackLayer()
    @_updateBackTextLayer()
    @_updateTextLayer()

    @_update()

  positionInPixels: -> @posToPixel(@_pos)

  widthInPixels: -> @_charWidth * @_size.x + @_padding * 2

  heightInPixels: -> @_charHeight * @_size.y + @_padding * 2

  sizeInPixels: -> @point(@_rect.width, @_rect.height)

  _showCursors: ->
    for c in @_cursors
      c.reset()._update()

  _hideCursors: ->
    for c in @_cursors
      c._state.visible = false
      c._update()

  _debugInfo: (container, level = 0) ->
    r = container.getLocalBounds()
    console.log "#{'    '.repeat(level)}#{container.name} (#{r.x}, #{r.y}, #{r.width}, #{r.height})"
    for c in container.children
      @_debugInfo(c, level + 1)

  _update: ->
    Swim.updates.addTerminal @
    return @

  _updateBackSprite: ->
    if !@_backSprite? or @_backSprite._width != @_charWidth or @_backSprite.height != @_charHeight
      g = new PIXI.Graphics()
      g.clear()
      g.beginFill(0xFFFFFF)
      g.drawRect(0, 0, @_charWidth, @_charHeight)
      g.endFill()
      t = g.generateTexture(Swim.renderer, 1, 0)
      if @_backSprite?
        @_backSprite.destroy()
      @_backSprite = new PIXI.Sprite(t)
      @_backSprite.cacheAsBitmap = true
      # @_backSprite.name = "BackSprite"
    return @

  _updateBackLayer: ->
    if @_backLayer._bg != @_palette.bg
      @_backLayer.clear()
      @_backLayer.beginFill(@_palette.bg)
      @_backLayer.drawRect(0, 0,  @_rect.width,  @_rect.height)
      @_backLayer.endFill()
      @_backLayer._bg = @_palette.bg
      # @_backLayer.name = "BackLayer"
      @_backLayer.cacheAsBitmap = false
      @_backLayer.cacheAsBitmap = true
    return @

  _updateTextLayer: ->
    @_textLayer.cacheAsBitmap = false
    @_textLayer.cacheAsBitmap = true
    for c in @_chars()
      c._letter.texture._updateUvs() if c._letter?
    # @_textLayer.name = "TextLayer"
    return @

  _updateBackTextLayer: ->
    @_backTextLayer.cacheAsBitmap = false
    @_backTextLayer.cacheAsBitmap = true
    # for c in @_chars()
    #   c._back.texture._updateUvs() if c._back?
    # @_backTextLayer.name = "BackTextLayer"
    return @

  _updateBorderLayer: ->
    if @_borderLayer? and (@_borderLayer._width != @_border.width or @_borderLayer._fg != @_border.fg or @_borderLayer._alpha != @_border.alpha)
      @_borderLayer.clear()
      @_borderLayer.lineStyle(@_border.width, @_border.fg, @_border.alpha)
      w = @_border.width * 0.5
      @_borderLayer.drawRect(w, w, Math.ceil(@_rect.width - w), Math.ceil(@_rect.height - w))
      # @_borderLayer.name = "BorderLayer"
      @_borderLayer._width = @_border.width
      @_borderLayer._fg = @_border.fg
      @_borderLayer._alpha = @_border.alpha
      @_borderLayer.cacheAsBitmap = false
      @_borderLayer.cacheAsBitmap = true
    return @

  _reorder: ->
    @children = _.sortBy(@children, (t) -> if t._z? then t._z else 0)
    return @

  _chars: ->
    cc = []
    for r in @_rows
      for c in r
        cc.push c if c?
    return cc

  chars: (rect) ->
    if !rect?
      r = @_tmpRect
      r.x = 0
      r.y = 0
      r.width = @_size.x - 1
      r.height = @_size.y - 1
    else
      r = rect
    cc = []
    for yy in [r.y..r.y + r.height]
      @_tmpPt.y = yy
      for xx in [r.x..r.x + r.width]
        @_tmpPt.x = xx
        c = @charAt(@_tmpPt)
        if c?
          cc.push c
    return cc

  charsAtRow: (y) ->
    r = @_tmpRect
    r.x = 0
    r.y = y
    r.width = @_size.x - 1
    r.height = y
    @chars(r)

  charsAtCol: (x) ->
    r = @_tmpRect
    r.x = x
    r.y = 0
    r.width = x
    r.height = @_size.y - 1
    @chars(r)

  isValidPos: (pos) ->
    pos.x >= 0 and pos.x < @_size.x and pos.y >= 0 and pos.y < @_size.y and @_rows.length > pos.y and @_rows[pos.y].length > pos.x

  charAt: (pos) ->
    if !@isValidPos(pos)
      return null
    c = @_rows[pos.y][pos.x]
    if !c?
      c = new TermChar(@, pos: pos, ch: ' ', fg: @_fg, bg: @_bg, font: @_font)
      @_rows[pos.y][pos.x] = c
    return c

  charAtPixel: (p) -> @charAt(@pixelToPos(p))

  setChar: (pos, config) ->
    c = @charAt(pos)
    if c?
      return c.set(config)
    else
      return null

  writeChar: (ch) ->
    for c in @_cursors
      cc = @setChar(c.pos, ch: ch, fg: @_fg, bg: @_bg, font: @_font)
      c.right(if cc? and cc.wide and !c.isEol() then 2 else 1)
    return @

  write: (text) ->
    @_font._cacheTextFrames(text)
    for t in text
      @writeChar(t)
    return @

  writeln: (text) -> @write("#{text}\n"); @

  posToIndex: (pos) -> pos.y * @_size.x + pos.x

  indexToPos: (index) -> t = Math.trunc(index / @_size.x); @point(index - (t * @_size.x), t)

  pixelToPos: (p) -> @point(Math.trunc((p.x - @_padding) / @_charWidth), Math.trunc((p.y - @_padding) / @_charHeight))

  posToPixel: (pos, skipParentPadding = false) ->
    p = @point(pos.x * @_charWidth, pos.y * @_charHeight)
    if !skipParentPadding and @parent? and @parent._padding
      p.x += @parent._padding - @_padding
      p.y += @parent._padding - @_padding
    else if @_padding
      p.x += @_padding
      p.y += @_padding
    p.x = Math.ceil(p.x)
    p.y = Math.ceil(p.y)
    return p

  charAtPixel: (p) -> @charAt(@pixelToPos(p))

  point: (x, y) -> new PIXI.Point(x, y)

  rectangle: (x, y, w, h) -> new PIXI.Rectangle(x, y, w, h)

  onDown: (e) ->
    pt = e.data.getLocalPosition(@)

    @setFocus()

    @_clickCount++

    if !@_pressed?
      @_pressed = {}

    @_pressed.time = Date.now()
    @_pressed.rightButton = @_isRightDown

    if !@_pressed.pixel?
      @_pressed.pixel = {}
    @_pressed.pixel.start = pt
    @_pressed.pixel.pos = pt
    @_pressed.pixel.distance = 0

    if !@_pressed.char?
      @_pressed.char = {}
    @_pressed.char.start = @pixelToPos(pt)
    @_pressed.char.pos = @pixelToPos(pt)
    @_pressed.char.distance = 0

    if @_clickCount == 1
      that = @
      @_dblClickTimer = setTimeout(->
        that._clickCount = 0
      , Swim.dblclickTime)
    else
      clearTimeout(@_dblClickTimer)
      @_dblClickTimer = null
      if @_pressed.pixel.pos.distance(@_lastPressed.pixel.pos) <= Swim.clickDistance
        @emit('dblclick', e)
      @_clickCount = 0

    e.stopPropagation()

  onMove: (e) ->
    if @_pressed?
      pt = e.data.getLocalPosition(@)
      cpt = @pixelToPos(pt)
      @_pressed.pixel.pos = pt
      @_pressed.char.pos = cpt
      @_pressed.pixel.distance = pt.distance(@_pressed.pixel.start)
      @_pressed.char.distance = cpt.distance(@_pressed.char.start)
      e.stopPropagation()

  onUp: (e) ->
    if @_pressed?
      pt = e.data.getLocalPosition(@)
      cpt = @pixelToPos(pt)
      if @_clickCount == 1 and @_pressed.pixel.distance <= Swim.clickDistance
        @emit('click', e)
      else
        @_lastPressed = _.deepClone(@_pressed)
        @_pressed = null
      e.stopPropagation()

    for t in Swim.terminals
      if t._pressed?
        t.onUp(e)

  onOver: (e) ->
    e.stopPropagation()

  onOut: (e) ->
    e.stopPropagation()

  onClick: (e) ->
    @_lastPressed = _.deepClone(@_pressed)
    @_pressed = null
    e.stopPropagation()

  onDblClick: (e) ->
    e.stopPropagation()

  blur: ->
    @_focused = false
    @emit 'blur'
    if @_document?
      @_document.emit 'blur'
    return @

  setFocus: ->
    if @focusable()
      for tt in Swim.terminals
        tt.blur()
      @_focused = true
      @emit 'focus'
      if @_document?
        @_document.emit 'focus'
    return @

  focusPrev: ->
    l = @_tabIndex
    @each (t) ->
      if t._tabIndex <= l and t != @
        t.setFocus()
        return true
    return @

  focusNext: ->
    l = @_tabIndex
    @each (t) ->
      if t._tabIndex >= l and t != @
        t.setFocus()
        return true
    return @

  setCursor: (pos) ->
    for c in @_cursors
      c.destroy()
    @_cursors = []
    @addCursor(pos)

  addCursor: (pos) ->
    c = new Swim.TermCursor(@, _.extend({}, @_cursorConfig, { pos: pos }))
    @_cursors.push c
    return c

  removeCursor: (pos) ->
    if pos instanceof PIXI.Point
      c = @cursorAt(pos)
    else if pos instanceof TermCursor
      c = pos
    else
      c = null
    if c?
      c.destroy()
      _.remove(@_cursors, c)
    return @

  moveCursor: (pos, newpos) ->
    if pos instanceof PIXI.Point
      c = @cursorAt(pos)
    else if pos instanceof TermCursor
      c = pos
    else
      c = null
    if c?
      c.moveTo(newpos)
    return @

  cursorAt: (pos) ->
    for c in @_cursors
      if c.pos.x == pos.x and c.pos.y == pos.y
        return c
    return null

  cursorAtPixel: (p) -> @cursorAt(@pixelToPos(p))

  erase: (rect) ->
    if !rect?
      r = @_tmpRect
      r.x = 0
      r.y = 0
      r.width = @_size.x - 1
      r.height = @_size.y - 1
    else
      r = rect
    p = @_tmpPt
    for yy in [r.y...r.y + r.height]
      p.y = yy
      for xx in [r.x...r.x + r.width]
        p.x = xx
        c = @charAt(@_tmpPt)
        if c?
          c.clear()
    return @

  eraseRow: (y) ->
    r = @_tmpRect
    r.x = 0
    r.y = y
    r.width = @_size.x - 1
    r.height = y
    @erase(r)

  eraseCol: (x) ->
    r = @_tmpRect
    r.x = x
    r.y = 0
    r.width = x
    r.height = @_size.y - 1
    @erase(r)

  eraseAt: (pos) ->
    if @isValidPos(pos)
      c = @_rows[pos.y][pos.x]
      if c?
        c.clear()
    return @

  copyto: (pos, newpos) ->
    c = @charAt(pos)
    if c?
      @setChar(newpos, ch: c._ch, fg: c._fg, bg: c._bg, font: c._font)
    return @

  moveTo: (pos, newpos) ->
    c = @charAt(pos)
    if c?
      @setChar(newpos, ch: c._ch, fg: c._fg, bg: c._bg, font: c._font)
      c.clear()
    return @

  switch: (pos, newpos) ->
    c = @charAt(pos)
    c2 = @charAt(newpos)
    if c? and c2?
      cc = { ch: c2._ch, fg: c2._fg, bg: c2._bg, font: c2._font }
      @setChar(newpos, ch: c._ch, fg: c._fg, bg: c._bg, font: c._font)
      @setChar(pos, ch: cc._ch, fg: cc._fg, bg: cc._bg, font: cc._font)
    return @

  scrollBy: (pos) ->
    p = @_tmpPt
    p2 = @_tmpPt2
    x = pos.x
    y = pos.y
    while y > 0
      for yy in [0..@_size.y - 2]
        p.y = yy
        p2.y = yy + 1
        for xx in [0...@_size.x]
          p.x = xx
          p2.x = xx
          @copyto(p2, p)
      @eraseRow(@_size.y - 1)
      @each (t) ->
        t._tmpPt.x = t.pos.x
        t._tmpPt.y = t.pos.y - 1
        t.pos = t._tmpPt
      y--

    while y < 0
      for yy in [@_size.y - 1..1]
        p.y = yy
        p2.y = yy - 1
        for xx in [0...@_size.x]
          p.x = xx
          p2.x = xx
          @copyto(p2, p)
      @eraseRow(0)
      @each (t) ->
        t._tmpPt.x = t.pos.x
        t._tmpPt.y = t.pos.y + 1
        t.pos = t._tmpPt
      y++

    while x > 0
      p.x = @_size.x - 1
      p2.x = @_size.x - 2
      for yy in [0...@_size.y]
        p.y = yy
        p2.y = yy
        @copyto(p2, p)
      @eraseCol(@_size.x - 1)
      @each (t) ->
        t._tmpPt.x = t.pos.x - 1
        t._tmpPt.y = t.pos.y
        t.pos = t._tmpPt
      x--

    while x < 0
      p.x = 0
      p2.x = 1
      for yy in [0...@_size.y]
        p.y = yy
        p2.y = yy
        @copyto(p2, p)
      @eraseCol(0)
      @each (t) ->
        t._tmpPt.x = t.pos.x + 1
        t._tmpPt.y = t.pos.y
        t.pos = t._tmpPt
      x++

    return @

  bindkey: (sequence, callback) ->
    if !@_keys?
      @_keys = new Swim.Keys(document.documentElement)

    c = (e) ->
      if @focused
        callback.apply(@, arguments)
        e.stopPropagation()

    @_keys.bind.call(@_keys, sequence, c.bind(@))

  terminalChildren: ->
    l = []
    for t in @children
      l.push t if t instanceof Terminal
    return l

  each: (cb) ->
    for t in @terminalChildren()
      if cb(t) == true
        break

  focusableChildren: ->
    l = []
    for t in @children
      l.push t if t instanceof Terminal
    return l

  bringToFront: ->
    z = 0
    @each (t) ->
      if t._z > z
        z = t._z
    @z = z + 1

  bringForward: ->
    @z++

  sendToBack: ->
    @each (t) ->
      t._z++
    @z = 0

  sendBackward: ->
    if @z > 0
      @z--

  focusable: ->
    @_tabIndex != -1

  toString: ->
    "Terminal rect: #{@rect} charBounds: (#{@_pos.x}, #{@_pos.y}, #{@_size.x}, #{@_size.y}) chars: #{@_chars().length} fg: #{@_fg} bg: #{@_bg} font: #{@_font.font()} options: #{@_options}"


Swim.TermChar = class TermChar

  PropertyAccessors.includeInto(@)

  @::accessor 'terminal',
    get: -> @_terminal
    set: (value) ->
      if @_terminal != value
        @_terminal = value
        @_update()

  @::accessor 'pos',
    get: -> @_pos
    set: (value) ->
      if @_pos != value
        @_pos = value.clone()
        @_update()

  @::accessor 'ch',
    get: -> @_ch
    set: (value) ->
      if @_ch != value
        @_ch = value
        @_wide = @_isWide(value)
        @_update()

  @::accessor 'fg',
    get: -> @_fg
    set: (value) ->
      if @_fg != value
        @_fg = value
        @_update()

  @::accessor 'bg',
    get: -> @_bg
    set: (value) ->
      if @_bg != value
        @_bg = value
        @_update()

  @::accessor 'font',
    get: -> @_font
    set: (value) ->
      if @_font != value
        @_font = value
        @_update()

  @::accessor 'wide',
    get: -> @_wide
    set: (value) ->
      if @_wide != value
        @_wide = value
        @_update()

  bgcol: (value) -> @bg = value; @

  fgcol: (value) -> @fg = value; @

  char: (value) -> @ch = value; @

  # font: (value) -> @font = value; @

  constructor: (terminal, config) ->
    @_letter = null
    @_back = null
    @_terminal = terminal
    if !config?
      config = {}
    @_pos = if config?.pos? then config.pos.clone() or @point()
    config.ch = config?.ch or ' '
    config.wide = @_isWide(config.ch)
    config.fg = config?.fg or @_terminal._fg
    config.bg = config?.bg or @_terminal._bg
    config.font = config?.font or @_terminal._font
    @set(config)

  destroy: ->
    console.log "Destroying #{@toString()}..."
    _.remove(Swim.updates.chars, @)

    if @_letter?
      @_letter.parent.removeChild(@_letter)
      @_letter.destroy()
      @_letter = null

    if @_back?
      @_back.parent.removeChild(@_back)
      @_back.destroy()
      @_back = null

    @_terminal = null
    @_font = null

  clear: (inherit = true) ->
    if inherit
      @set ch: ' ', fg: @_terminal._fg, bg: @_terminal._bg, font: @_terminal._font
    else
      @set ch: ' ', fg: @_terminal.white, bg: @_terminal.black, font: @_terminal._font

  set: (config) ->
    if config?
      update = false
      if config.pos? and (config.pos.x != @_pos.x or config.pos.y != @_pos.y)
        @_pos = config.pos.clone()
        update = true
      if config.ch? and config.ch != @_ch
        @_ch = config.ch
        @_wide = @_isWide(@_ch)
        update = true
      if config.fg? and config.fg != @_fg
        @_fg = config.fg
        update = true
      if config.bg? and config.bg != @_bg
        @_bg = config.bg
        update = true
      if config.font? and config.font != @_font
        @_font = config.font
        update = true
      if update
        @_update()
    return @

  _isWide: (ch) ->
    ch.charCodeAt(0) >= 0xf000

  _update: ->
    Swim.updates.addChar @
    return @

  toString: ->
    "TermChar ch: #{@_ch} (#{@_pos.x}, #{@_pos.y}) fg: #{@_fg} bg: #{@_bg} font: #{@_font.contextFont()}"
