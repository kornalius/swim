{ Plugin, PIXI, PropertyAccessors, EventEmitter, Mode } = Swim

Swim.terminals = []

Swim.renderer.view.addEventListener 'wheel', (e) ->
  t = Swim.currentOver()
  if t? and t._options.scrollable? and (t._options.scrollable.x or t._options.scrollable.y)
    res = -120
    deltaX = 0
    deltaY = 0

    if t._options.scrollable.x
      deltaX = e.wheelDeltaX * res
      if deltaX <= res
        deltaX = -1
      else if deltaX > res
        deltaX = 1

    if t._options.scrollable.y
      deltaY = e.wheelDeltaY * res
      if deltaY <= res
        deltaY = -1
      else if deltaY > res
        deltaY = 1

    t._scrollwheel =
      delta: t.point(deltaX, deltaY)

    t.onScroll(e)

  e.stopPropagation()

  return false
,false

Swim.currentOver = ->
  m = Swim.renderer.plugins.interaction.mouse.global
  for t in Swim.terminals
    h = t.childAt(m)
    return h if h?
  return null

Swim.clickDistance = 8
Swim.dblclickTime = 350

Swim.ico = '\x1c'
Swim.icof = '\x1d'

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

  @::accessor 'bold',
    get: -> @_bold
    set: (value) ->
      if @_bold != value
        @_bold = value
        @_font = Swim.getFont(_.extend({}, @_font.getConfig(), bold: value))

  @::accessor 'italic',
    get: -> @_italic
    set: (value) ->
      if @_italic != value
        @_italic = value
        @_font = Swim.getFont(_.extend({}, @_font.getConfig(), italic: value))

  @::accessor 'underline',
    get: -> @_underline
    set: (value) ->
      if @_underline != value
        @_underline = value
        @_font = Swim.getFont(_.extend({}, @_font.getConfig(), underline: value))

  @::accessor 'strike',
    get: -> @_strike
    set: (value) ->
      if @_strike != value
        @_strike = value

  @::accessor 'conceal',
    get: -> @_conceal
    set: (value) ->
      if @_conceal != value
        @_conceal = value

  @::accessor 'reverse',
    get: -> @_reverse
    set: (value) ->
      if @_reverse != value
        @_reverse = value

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

  @::accessor '$fg',         -> @fg = @_palette.fg; @
  @::accessor 'black',       -> @fg = @_palette.black; @
  @::accessor 'red',         -> @fg = @_palette.red; @
  @::accessor 'green',       -> @fg = @_palette.green; @
  @::accessor 'yellow',      -> @fg = @_palette.yellow; @
  @::accessor 'blue',        -> @fg = @_palette.blue; @
  @::accessor 'magenta',     -> @fg = @_palette.magenta; @
  @::accessor 'cyan',        -> @fg = @_palette.cyan; @
  @::accessor 'white',       -> @fg = @_palette.white; @
  @::accessor 'brblack',     -> @fg = @_palette.brblack; @
  @::accessor 'brred',       -> @fg = @_palette.brred; @
  @::accessor 'brgreen',     -> @fg = @_palette.brgreen; @
  @::accessor 'bryellow',    -> @fg = @_palette.bryellow; @
  @::accessor 'brblue',      -> @fg = @_palette.brblue; @
  @::accessor 'brmagenta',   -> @fg = @_palette.brmagenta; @
  @::accessor 'brcyan',      -> @fg = @_palette.brcyan; @
  @::accessor 'brwhite',     -> @fg = @_palette.brwhite; @

  @::accessor '$bg',         -> @bg = @_palette.bg; @
  @::accessor 'bgblack',     -> @bg = @_palette.black; @
  @::accessor 'bgred',       -> @bg = @_palette.red; @
  @::accessor 'bggreen',     -> @bg = @_palette.green; @
  @::accessor 'bgyellow',    -> @bg = @_palette.yellow; @
  @::accessor 'bgblue',      -> @bg = @_palette.blue; @
  @::accessor 'bgmagenta',   -> @bg = @_palette.magenta; @
  @::accessor 'bgcyan',      -> @bg = @_palette.cyan; @
  @::accessor 'bgwhite',     -> @bg = @_palette.white; @
  @::accessor 'bgbrblack',   -> @bg = @_palette.brblack; @
  @::accessor 'bgbrred',     -> @bg = @_palette.brred; @
  @::accessor 'bgbrgreen',   -> @bg = @_palette.brgreen; @
  @::accessor 'bgbryellow',  -> @bg = @_palette.bryellow; @
  @::accessor 'bgbrblue',    -> @bg = @_palette.brblue; @
  @::accessor 'bgbrmagenta', -> @bg = @_palette.brmagenta; @
  @::accessor 'bgbrcyan',    -> @bg = @_palette.brcyan; @
  @::accessor 'bgbrwhite',   -> @bg = @_palette.brwhite; @

  colorFromIndex: (index) -> @colorFromName(_.drop(_.keys(@_palette), 2)[index])
  color256FromIndex: (index) -> Swim.ANSI.colors256[index]
  colorFromName: (name) -> @_palette[name]
  colorFromValue: (value) -> return k if v == value for k, v of @_palette
  colorIndexFromName: (name) -> _.drop(_.keys(@_palette), 2).indexOf(name)
  colorIndexFromValue: (value) -> _.drop(_.values(@_palette), 2).indexOf(value)

  @::accessor 'b', -> @bold = true; @
  @::accessor 'i', -> @italic = true; @
  @::accessor 'u', -> @underline = true; @
  @::accessor 's', -> @strike = true; @
  @::accessor 'c', -> @conceal = true; @
  @::accessor 'r', -> @reverse = true; @

  @::accessor 'reset', -> @_fg = @_palette.fg; @_bg = @_palette.bg; @_bold = false; @_italic = false; @_underline = false; @_strike = false; @_conceal = false; @_reverse = false; @_update(); @

  @::accessor 'bol',    -> c.bol() for c in @_cursors; @
  @::accessor 'eol',    -> c.eol() for c in @_cursors; @
  @::accessor 'left',   -> c.left() for c in @_cursors; @
  @::accessor 'right',  -> c.right() for c in @_cursors; @
  @::accessor 'up',     -> c.up() for c in @_cursors; @
  @::accessor 'down',   -> c.down() for c in @_cursors; @
  @::accessor 'cr',     -> c.cr() for c in @_cursors; @
  @::accessor 'lf',     -> c.lf() for c in @_cursors; @
  @::accessor 'home',   -> c.home() for c in @_cursors; @
  @::accessor 'end',    -> c.end() for c in @_cursors; @
  @::accessor 'bs',     -> c.bs() for c in @_cursors; @
  @::accessor 'del',    -> c.del() for c in @_cursors; @
  @::accessor 'tab',    -> c.tab() for c in @_cursors; @
  @::accessor 'cls',    -> @erase().home
  @::accessor 'bell',   -> ion.sound.play('bell'); @

  @::accessor 'kline',  -> @eraseRow(c.pos.y) for c in @_cursors; @

  @::accessor 'kbol',   -> @erase(@rectangle(0, c.pos.y, c.pos.x - 1, 1)) for c in @_cursors; @

  @::accessor 'keol',   -> @erase(@rectangle(c.pos.x, c.pos.y, @_size.x - c.pos.x - 1, 1)) for c in @_cursors; @

  @::accessor 'khome',  -> @erase(@rectangle(0, c.pos.y, c.pos.x - 1, 1)); @erase(@rectangle(0, 0, @_size.x - 1, c.pos.y - 1)) for c in @_cursors; @

  @::accessor 'kend',   -> @erase(@rectangle(c.pos.x, c.pos.y, @_size.x - c.pos.x - 1, 1)); @erase(@rectangle(0, c.pos.y + 1, @_size.x - 1, @_size.y - 1)) for c in @_cursors; @

  @::accessor 'scur', -> @saveCursors(); @

  @::accessor 'rcur', -> @restoreCursors(); @

  @::accessor 'ssta', -> @saveStates(); @

  @::accessor 'rsta', -> @restoreStates(); @

  icon: (name) -> "#{Swim.ico}#{Swim.icons[name]}#{Swim.icof}"

  constructor: (config) ->
    super

    @_id = _.uniqueId()

    @_z = 0
    @_focused = false
    @_prevBlink = Date.now()
    @_tabIndex = -1

    @_savedCursors = []
    @_savedStates = []

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
    @_size = config?.size or @point()
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
      _.extend @_options, config.options

    @_cursorConfig =
      width: @_charWidth
      height: @_charHeight
      offset: @point()
      wrap: true
      blink: 500
      type: 'block'

    if config?.cursor?
      _.extend @_cursorConfig, config.cursor

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

    @_focusStyle = config?.focusStyle or { width: 2, offset: 3, fg: @_palette.cyan, alpha: 0.75 }

    @interactive = true

    @position = @positionInPixels()
    @_rect = @rectangle(@position.x, @position.y, @widthInPixels(), @heightInPixels())

    # @filters = [f]

    @_clickCount = 0
    @_dblClickTimer = null

    @on 'mousedown', @onDown, @
    @on 'rightdown', @onDown, @
    @on 'mousemove', @onMove, @
    @on 'mouseup', @onUp, @
    @on 'rightup', @onUp, @
    # @on 'mouseout', @onOut, @
    # @on 'mouseover', @onOver, @

    @on 'touchstart', @onDown, @
    @on 'touchmove', @onMove, @
    @on 'touchup', @onUp, @

    @on 'click', @onClick, @
    @on 'dblclick', @onDblClick, @

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

    @_focusLayer = new PIXI.Graphics()
    @_focusLayer.cacheAsBitmap = true
    @addChild(@_focusLayer)

    @_cursors = [new Swim.TermCursor(@, @_cursorConfig)]

    @_tmpPt = @point()
    @_tmpPt2 = @point()
    @_tmpRect = @rectangle()

    Swim.terminals.push @

    ee = Swim.CustomEvent target: @
    @modes_emit 'terminal.created', ee

    @clear()

    @_cursorsTick = (time) =>
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

    PIXI.ticker.shared.add @_cursorsTick

  destroy: ->
    ee = Swim.CustomEvent target: @
    @modes_emit 'terminal.destroyed', ee

    if !ee.defaultPrevented
      # console.log "Destroying #{@toString()}..."

      PIXI.ticker.shared.remove(@_cursorsTick)

      for m in @_modes
        m.destroy()
      @_modes = []

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

      @_focusLayer.removeChildren()
      @_focusLayer.parent.removeChild(@_focusLayer)
      @_focusLayer = null

      @_rect = null

      _.remove(Swim.terminals, @)

      super

  attached: ->
    ee = Swim.CustomEvent target: @
    @modes_emit 'terminal.attached', ee
    if !ee.defaultPrevented
      @position = @positionInPixels()
      @_rect = @rectangle(@position.x, @position.y, @widthInPixels(), @heightInPixels())

  detached: ->
    ee = Swim.CustomEvent target: @
    @modes_emit 'terminal.detached', ee

  modes_emit: (e) ->
    for m in @_modes
      m.emit e
      if e.defaultPrevented
        break

  addTerminal: (t) ->
    r = @addChild(t)
    @_reorder()
    t.attached()
    return r

  removeTerminal: (t) ->
    t.detached()
    r = @removeChild(t)
    @_reorder()
    return r

  clear: ->
    ee = Swim.CustomEvent target: @
    @modes_emit 'terminal.clear', ee
    if !ee.defaultPrevented
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
    if @_backLayer._bg != @_bg or @_backLayer._width != @_rect.width or @_backLayer.height != @_rect.height
      @_backLayer.clear()
      @_backLayer.beginFill(@_bg)
      @_backLayer.drawRect(0, 0,  @_rect.width,  @_rect.height)
      @_backLayer.endFill()
      @_backLayer._bg = @_bg
      # @_backLayer.name = "BackLayer"
      @_backLayer.cacheAsBitmap = false
      @_backLayer.cacheAsBitmap = true
    return @

  _updateTextLayer: ->
    @_textLayer.cacheAsBitmap = false
    @_textLayer.cacheAsBitmap = true
    for c in @_chars()
      c._updateUvs()
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

  _updateFocusLayer: ->
    @_focusLayer.clear()
    @_focusLayer.lineStyle(@_focusStyle.width, @_focusStyle.fg, @_focusStyle.alpha)
    w = @_focusStyle.width * 0.5
    @_focusLayer.drawRect(w - @_focusStyle.offset, w - @_focusStyle.offset, Math.ceil(@_rect.width - w + @_focusStyle.offset * 2), Math.ceil(@_rect.height - w + @_focusStyle.offset * 2))
    @_focusLayer.cacheAsBitmap = false
    @_focusLayer.cacheAsBitmap = true
    @_focusLayer.visible = @_focused
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
    return null

  _writeChar: (ch) ->
    for c in @_cursors
      cc = @setChar(c.pos, ch: ch, fg: @_fg, bg: @_bg, font: @_font)
      c.right(if cc? and cc.wide and !c.isEol() then 2 else 1)
    return @

  _write: (text) ->
    ee = Swim.CustomEvent target: @, text: text
    @modes_emit 'terminal.write', ee
    if !ee.defaultPrevented
      @_font._cacheTextFrames(text)
      for c in text
        if c == Swim.ico
          @_icon_mode = true
        else if c == Swim.icof
          @_icon_mode = false
        else
          @_writeChar c
    return @

  write: (text) ->
    if Swim.ANSI? and /[\x01-\x1b]/g.test text
      Swim.ANSI.ansi_to_swim @, text
    else
      @_write text
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

  isMouseOver: -> Swim.currentOver() == @

  childAt: (point) ->
    for c in @_interactiveChildren()
      if c.childAt?
        hc = c.childAt(point)
        return hc if hc?

      if c.hitArea?
        c.worldTransform.applyInverse(point, @_tmpPt)
        return c if c.hitArea.contains(@_tmpPt.x, @_tmpPt.y)

      else if c.containsPoint? and c.containsPoint(point)
        return c

      else if c.getBounds().contains(point.x, point.y)
        return c

    if @getBounds().contains(point.x, point.y)
      return @
    else
      return null

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

    ee = Swim.CustomEvent target: @, event: e
    @modes_emit 'terminal.mousedown', ee

    if !ee.defaultPrevented
      if @_clickCount == 1
        that = @
        @_dblClickTimer = setTimeout(->
          that._clickCount = 0
        , Swim.dblclickTime)
      else
        clearTimeout(@_dblClickTimer)
        @_dblClickTimer = null
        if @_pressed.pixel.pos.distance(@_lastPressed.pixel.pos) <= Swim.clickDistance
          @emit 'dblclick', e
        @_clickCount = 0
    else
      e.preventDefault()

    e.stopPropagation()

  onMove: (e) ->
    if @_pressed?
      pt = e.data.getLocalPosition(@)
      cpt = @pixelToPos(pt)
      @_pressed.pixel.pos = pt
      @_pressed.char.pos = cpt
      @_pressed.pixel.distance = pt.distance(@_pressed.pixel.start)
      @_pressed.char.distance = cpt.distance(@_pressed.char.start)
      ee = Swim.CustomEvent target: @, event: e
      @modes_emit 'terminal.mousemove', ee
      if ee.defaultPrevented
        e.preventDefault()
      e.stopPropagation()

  onUp: (e) ->
    if @_pressed?
      pt = e.data.getLocalPosition(@)
      cpt = @pixelToPos(pt)
      if @_clickCount == 1 and @_pressed.pixel.distance <= Swim.clickDistance
        @emit 'click', e
      else
        @_lastPressed = _.clone(@_pressed)
        @_pressed = null
      ee = Swim.CustomEvent target: @, event: e
      @modes_emit 'terminal.mouseup', ee
      if ee.defaultPrevented
        e.preventDefault()
      e.stopPropagation()

    for t in Swim.terminals
      if t._pressed?
        t.emit 'mouseup', e

  # onOver: (e) ->
  #   ee = Swim.CustomEvent target: @, event: e
  #   @modes_emit 'terminal.mouseover', ee
  #   if ee.defaultPrevented
  #     e.preventDefault()
  #   console.log "OVER: ", @_over

  # onOut: (e) ->
  #   # _.remove(Swim._overs, @)
  #   e.detail = target: @
  #   ee = Swim.CustomEvent target: @, event: e
  #   @modes_emit 'terminal.mouseout', ee
  #   if ee.defaultPrevented
  #     e.preventDefault()

  onClick: (e) ->
    @_lastPressed = _.clone(@_pressed)
    ee = Swim.CustomEvent target: @, event: e
    @modes_emit 'terminal.click', ee
    if ee.defaultPrevented
      e.preventDefault()
    @_pressed = null
    e.stopPropagation()

  onDblClick: (e) ->
    ee = Swim.CustomEvent target: @, event: e
    @modes_emit 'terminal.dblclick', ee
    if ee.defaultPrevented
      e.preventDefault()
    e.stopPropagation()

  onScroll: (e) ->
    ee = Swim.CustomEvent target: @, event: e
    @modes_emit 'terminal.mousescroll', ee
    if ee.defaultPrevented
      e.preventDefault()

  blur: ->
    ee = Swim.CustomEvent target: @
    @modes_emit 'terminal.blur', ee
    if !ee.defaultPrevented
      @_focused = false
      @_update()
    return @

  setFocus: ->
    if @focusable()
      ee = Swim.CustomEvent target: @
      @modes_emit 'terminal.focus', ee
      if !ee.defaultPrevented
        for tt in Swim.terminals
          tt.blur()
        @_focused = true
        @_update()
    return @

  focusPrev: ->
    l = @_tabIndex
    @each (t) ->
      if t._tabIndex <= l and t != @
        t.setFocus()
        return t._focused
    return @

  focusNext: ->
    l = @_tabIndex
    @each (t) ->
      if t._tabIndex >= l and t != @
        t.setFocus()
        return t._focused
    return @

  setCursor: (cursor, pos) ->
    if cursor instanceof Swim.PIXI.Point
      pos = cursor
      cursor = null
    if !cursor?
      if @_cursors.length == 0
        cursor = @addCursor(pos)
      else
        cursor = @cursor
    cursor.moveTo(pos)
    return cursor

  addCursor: (pos) ->
    cursor = new Swim.TermCursor(@, _.extend({}, @_cursorConfig, { pos: pos }))
    @_cursors.push cursor
    cursor.attached()
    return cursor

  removeCursor: (pos) ->
    if pos instanceof PIXI.Point
      cursor = @cursorAt(pos)
    else if pos instanceof TermCursor
      cursor = pos
    else
      cursor = null
    if cursor?
      cursor.detached()
      cursor.destroy()
      _.remove(@_cursors, cursor)
    return @

  moveCursor: (pos, newpos) ->
    if pos instanceof PIXI.Point
      cursor = @cursorAt(pos)
    else if pos instanceof TermCursor
      cursor = pos
    else
      cursor = null
    if cursor?
      cursor.moveTo(newpos)
    return @

  cursorAt: (pos) ->
    for c in @_cursors
      if c.pos.x == pos.x and c.pos.y == pos.y
        return c
    return null

  cursorAtPixel: (p) -> @cursorAt(@pixelToPos(p))

  cursorPos: (cursor) ->
    if !cursor?
      cursor = @cursor
    cursor.pos

  saveCursors: ->
    sc = []
    for c in @_cursors
      sc.push c.pos.clone()
    @_savedCursors.push sc
    return @

  restoreCursors: ->
    if @_savedCursors.length > 0
      for c in @_cursors
        c.detached()
        c.destroy()
      @_cursors = []
      for pos in @_savedCursors.pop()
        @addCursor pos
    return @

  showCursors: ->
    for c in @_cursors
      c.reset()._update()

  hideCursors: ->
    for c in @_cursors
      c._state.visible = false
      c._update()

  eraseFixed: (x, y, x2, y2) ->
    r = @_tmpRect
    r.x = x
    r.y = y
    r.width = x2 - x + 1
    r.height = y2 - y + 1
    @erase @_tmpRect

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

  insertRow: (y, count) ->
    if !count?
      count = 1
    @_tmpPt.x = 0
    @_tmpPt.y = count
    @scrollBy(@_tmpPt, y)

  deleteRow: (y, count) ->
    if !count?
      count = 1
    @_tmpPt.x = 0
    @_tmpPt.y = -count
    @scrollBy(@_tmpPt, y)

  scrollBy: (pos, row) ->
    if !row?
      row = 0
    ee = Swim.CustomEvent target: @, pos: pos
    @modes_emit 'terminal.scrollby', ee
    if !ee.defaultPrevented
      p = @_tmpPt
      p2 = @_tmpPt2
      x = pos.x
      y = pos.y
      while y > 0
        for yy in [row..@_size.y - 2]
          p.y = yy
          p2.y = yy + 1
          for xx in [0...@_size.x]
            p.x = xx
            p2.x = xx
            @copyto(p2, p)
        if row > 0
          @eraseRow(row)
        else
          @eraseRow(@_size.y - 1)
        @each (t) ->
          if t.pos.y >= row
            t._tmpPt.x = t.pos.x
            t._tmpPt.y = t.pos.y - 1
            t.pos = t._tmpPt
        y--

      while y < 0
        for yy in [@_size.y - 1..row + 1]
          p.y = yy
          p2.y = yy - 1
          for xx in [0...@_size.x]
            p.x = xx
            p2.x = xx
            @copyto(p2, p)
        @eraseRow(row)
        @each (t) ->
          if t.pos.y < row
            t._tmpPt.x = t.pos.x
            t._tmpPt.y = t.pos.y + 1
            t.pos = t._tmpPt
        y++

      while x > 0
        p.x = @_size.x - 1
        p2.x = @_size.x - 2
        for yy in [row...@_size.y]
          p.y = yy
          p2.y = yy
          @copyto(p2, p)
        @eraseCol(@_size.x - 1)
        @each (t) ->
          if t.pos.y >= row
            t._tmpPt.x = t.pos.x - 1
            t._tmpPt.y = t.pos.y
            t.pos = t._tmpPt
        x--

      while x < 0
        p.x = 0
        p2.x = 1
        for yy in [row...@_size.y]
          p.y = yy
          p2.y = yy
          @copyto(p2, p)
        @eraseCol(0)
        @each (t) ->
          if t.pos.y >= row
            t._tmpPt.x = t.pos.x + 1
            t._tmpPt.y = t.pos.y
            t.pos = t._tmpPt
        x++

    return @

  bindkey: (sequence, callback) ->
    if !@_keys?
      @_keys = new Swim.Keys(document.documentElement)

    ee = Swim.CustomEvent target: @, sequence: sequence
    @modes_emit 'terminal.keybind', ee
    if !ee.defaultPrevented
      fn = (e) =>
        if @focused
          ee = Swim.CustomEvent target: @
          @modes_emit sequence, ee
          if !ee.defaultPrevented
            callback.apply(@, arguments)
          e.stopPropagation()

      @_keys.bind.call(@_keys, sequence, fn)

  terminalChildren: ->
    l = []
    for t in @children
      l.push t if t instanceof Terminal
    return _.sortBy(l, '_z')

  _interactiveChildren: ->
    l = []
    for t in @terminalChildren()
      l.push t if t.interactive
    return _.sortBy(l, '_z')

  focusableChildren: (gt = -1) ->
    l = []
    for t in @terminalChildren()
      if t.tabIndex > gt
        l.push t
    return _.sortBy(l, '_z')

  each: (cb) ->
    for t in @terminalChildren()
      if cb(t) == true
        break

  bringToFront: ->
    z = 0
    @each (t) ->
      if t._z > z
        z = t._z
    ee = Swim.CustomEvent target: @, z: z + 1
    @modes_emit 'terminal.zindex', ee
    if !ee.defaultPrevented
      @z = z + 1

  bringForward: ->
    ee = Swim.CustomEvent target: @, z: @z + 1
    @modes_emit 'terminal.zindex', ee
    if !ee.defaultPrevented
      @z++

  sendToBack: ->
    ee = Swim.CustomEvent target: @, z: 0
    @modes_emit 'terminal.zindex', ee
    if !ee.defaultPrevented
      @each (t) ->
        t._z++
      @z = 0

  sendBackward: ->
    ee = Swim.CustomEvent target: @, z: @z - 1
    @modes_emit 'terminal.zindex', ee
    if !ee.defaultPrevented
      if @z > 0
        @z--

  focusable: ->
    @_tabIndex != -1

  addMode: (mode) ->
    if !_.contains(@_modes, mode)
      @_modes.push mode
      mode.attached()

  removeMode: (mode) ->
    if _.contains(@_modes, mode)
      mode.detached()
      mode.destroy()
      _.remove(@_modes, mode)

  saveStates: ->
    @_savedStates.push
      fg: @_fg
      bg: @_bg
      font: @_font
      bold: @_bold
      italic: @_italic
      underline: @_underline
      conceal: @_conceal
      strike: @_strike
    return @

  restoreStates: ->
    if @_savedStates.length > 0
      ss = @_savedStates.pop()
      @_fg = ss.fg
      @_bg = ss.bg
      @_font = ss.font
      @_bold = ss.bold
      @_italic = ss.italic
      @_underline = ss.underline
      @_conceal = ss.conceal
      @_strike = ss.strike
    return @

  toString: ->
    "Terminal rect: #{@rect} charBounds: (#{@_pos.x}, #{@_pos.y}, #{@_size.x}, #{@_size.y}) chars: #{@_chars().length} fg: #{@_fg} bg: #{@_bg} font: #{@_font.toString()} options: #{@_options}"


Swim.TermChar = class TermChar extends EventEmitter

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

  @::accessor 'layers',
    get: -> @_layers
    set: (value) ->
      if @_layers != value
        @clearLayers()
        @_layers = value
        @_update()

  bgcol: (value) -> @bg = value; @

  fgcol: (value) -> @fg = value; @

  char: (value) -> @ch = value; @

  # font: (value) -> @font = value; @

  constructor: (terminal, config) ->
    EventEmitter @
    @_letter = null
    @_back = null
    @_terminal = terminal
    @_layers = []
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
    # console.log "Destroying #{@toString()}..."
    _.remove(Swim.updates.chars, @)

    if @_letter?
      @_letter.parent.removeChild(@_letter)
      @_letter.destroy()
      @_letter = null

    if @_back?
      @_back.parent.removeChild(@_back)
      @_back.destroy()
      @_back = null

    for l in @_layers
      l.destroy()
    @_layers = []

    @_terminal = null
    @_font = null

  modes_emit: ->
    for m in @_terminal._modes
      m.emit(arguments...)

  clear: (inherit = true) ->
    if inherit
      @set ch: ' ', fg: @_terminal._fg, bg: @_terminal._bg, font: @_terminal._font
    else
      @set ch: ' ', fg: @_terminal.white, bg: @_terminal.black, font: @_terminal._font

  set: (config) ->
    if config?
      update = false
      ee = Swim.CustomEvent target: @, to_apply: config
      @modes_emit 'terminal.setchar', ee
      if !ee.defaultPrevented
        if @_terminal._icon_mode and config.font != Swim.iconFont
          config.font = Swim.iconFont
        if config.pos? and (config.pos.x != @_pos.x or config.pos.y != @_pos.y)
          @_pos.x = config.pos.x
          @_pos.y = config.pos.y
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
        if config.layers?
          @clearLayers()
          for l in config.layers
            @addLayer l
          update = true
        if update
          @_update()
    return @

  _isWide: (ch) ->
    ch >= '\uf000'

  _update: ->
    Swim.updates.addChar @
    for l in @_layers
      Swim.updates.addChar l
    return @

  _updateUvs: ->
    @_letter.texture._updateUvs() if @_letter?
    for l in @_layers
      l._updateUvs()

  clearLayers: ->
    for l in @_layers
      l.destroy()
    @_layers = []
    return @

  findLayer: (config) ->
    if config?
      for l in @_layers
        if config.ch? and config.ch == l._ch
          return l
    return null

  addLayer: (config) ->
    if !@findLayer(config)
      lc = new TermChar(@_terminal, _.extend({}, {pos: @_pos, fg: @_fg, font: @_font}, config))
      lc._parent = @
      @_layers.push lc
      @_update()
    return @

  delLayer: (config) ->
    if config?
      l = @findLayer(config)
      if l?
        l.destroy()
        _.remove(@_layers, l)
      @_update()
    return @

  toString: ->
    "TermChar ch: #{@_ch} (#{@_pos.x}, #{@_pos.y}) fg: #{@_fg} bg: #{@_bg} font: #{@_font.contextFont()}"
