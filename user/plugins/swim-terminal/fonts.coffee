{ Plugin, PIXI, PropertyAccessors, EventEmitter } = Swim

cc = 0

Swim.fonts = []
Swim.getFont = (config) ->
  for f in Swim.fonts
    if (!config?.path? or f._path == config.path) and (!config?.name? or f._name == config.name) and (!config?.size? or f._size == config.size) and (!config?.bold? or f._bold == config.bold) and (!config?.italic? or f._italic == config.italic) and (!config?.underline? or f._underline == config.underline) and (!config?.smooth? or f._smooth == config.smooth)
      return f
  f = new TermFont(config)
  Swim.fonts.push(f)
  return f


Swim.TermFont = class TermFont extends EventEmitter

  PropertyAccessors.includeInto(@)

  @::accessor 'bitmap',
    get: -> @_bitmap
    set: (value) ->
      if @_bitmap != value
        @_bitmap = value
        @_update()

  @::accessor 'name',
    get: -> @_name
    set: (value) ->
      if @_name != value
        @_name = value
        @_update()

  @::accessor 'size',
    get: -> @_size
    set: (value) ->
      if @_size != value
        @_size = value
        @_update()

  @::accessor 'bold',
    get: -> @_bold
    set: (value) ->
      if @_bold != value
        @_bold = value
        @_update()

  @::accessor 'italic',
    get: -> @_italic
    set: (value) ->
      if @_italic != value
        @_italic = value
        @_update()

  @::accessor 'underline',
    get: -> @_underline
    set: (value) ->
      if @_underline != value
        @_underline = value
        @_update()

  @::accessor 'smooth',
    get: -> @_smooth
    set: (value) ->
      if @_smooth != value
        @_smooth = value
        @_update()

  @::accessor 'loaded', -> @_loaded

  constructor: (config) ->
    EventEmitter @
    @_cached = []
    @_path = config?.path or null
    @_name = config?.name or 'Arial'
    @_size = config?.size or 16
    @_bold = config?.bold == true
    @_italic = config?.italic == true
    @_underline = config?.underline == true
    @_smooth = config?.smooth == true
    @_bitmap = false
    @_loaded = true

    ee = Swim.CustomEvent target: @
    @modes_emit 'font.created', ee

    if @_path?
      @_loaded = false

      style = document.createElement('style')
      style.textContent = "\n
        @font-face {\n
          font-family: '#{@_name}';\n
          src: url('#{@_path}') format('truetype');\n
        }\n
        \n"
      style.setAttribute("type", "text/css")
      document.head.appendChild(style)

      @_loader = document.createElement('span')
      @_loader.textContent = "#{@_name} \ue61b \ue646"
      @_loader.style.display = 'hidden'
      # @_loader.style.position = 'absolute'
      # @_loader.style.left = '-1000px'
      # @_loader.style.opacity = '0'
      @_loader.style.color = 'white'
      @_loader.style.fontFamily = @_name
      @_loader.style.fontSize = @_size
      document.body.appendChild(@_loader)

      @_oldLoaderWidth = @_loader.offsetWidth

      that = @

      _check = ->
        # console.log that._loader.offsetWidth, that._oldLoaderWidth
        if !that._oldLoaderWidth? or that._loader.offsetWidth == that._oldLoaderWidth
          setTimeout _check, 10
        else
          that._loaded = true
          ee = Swim.CustomEvent target: that
          that.modes_emit 'font.loaded', ee
          that.clear()._update()

      setTimeout _check, 10

  modes_emit: (e) ->
    for t in Swim.terminals
      for m in t._modes
        m.emit e
        if e.defaultPrevented
          break

  clear: ->
    ee = Swim.CustomEvent target: @
    @modes_emit 'font.clear', ee
    for lc in @_cached
      lc.clear()
      cc--
    @_cached = []
    return @

  destroy: ->
    ee = Swim.CustomEvent target: @
    @modes_emit 'font.destroyed', ee
    # console.log "Destroying #{@toString()}..."
    for lc in @_cached
      lc.destroy()
    @_cached = []

  _update: ->
    Swim.updates.addFont @
    return @

  frame: (ch) -> @_cacheFrame(ch)

  _getFrame: (ch) ->
    for l in @_cached
      r = l._getFrame(ch)
      if r?
        return { line: l, ch: ch, frame: r }
    return null

  _cacheFrame: (ch) ->
    r = @_getFrame(ch)
    return r if r?
    if _.isEmpty(@_cached)
      @_cached.push new TermFontLine(@, 0)
    lc = _.last(@_cached)
    if !lc._canCache(ch)
      @_cached.push new TermFontLine(@, lc.length)
      lc = _.last(@_cached)
    r = lc._cacheFrame(ch)
    if r?
      return { line: lc, ch: ch, frame: r }
    else
      return null

  _cacheTextFrames: (text) ->
    for ch in text
      @_cacheFrame(ch)
    @_update()

  contextFont: ->
    "#{if @_bold then "bold " else ""}#{if @_italic then "italic " else ""}#{if @_underline then "underline " else ""}#{@_size}px '#{@_name}'"

  getConfig: ->
    path: @_path
    name: @_name
    size: @_size
    bold: @_bold
    italic: @_italic
    underline: @_underline
    smooth: @_smooth

  toString: ->
    "TermFont #{@contextFont()} #{if @_smooth then " smooth" else ""}"


Swim.TermFontLine = class TermFontLine extends EventEmitter

  PropertyAccessors.includeInto(@)

  @::accessor 'length',
    get: -> @_text.text.length

  @::accessor 'text',
    get: -> @_text.text

  @::accessor 'texture',
    get: -> @_text.texture

  constructor: (parent, index) ->
    EventEmitter @
    @_parent = parent
    @_index = index or 0
    @_MAX = 2048
    @clear()
    @_build()
    # @_text.context.imageSmoothingEnabled = false
    # @_text.context.webkitImageSmoothingEnabled = false
    # console.log @_text.context.imageSmoothingEnabled, @_text.context

  _build: ->
    @_text = new PIXI.Text '', font: @_parent.contextFont(), fill: 0xFFFFFF, padding: 4
    @_text.canvas.style.display = "hidden";
    document.body.appendChild(@_text.canvas)
    @_text.canvas.style['font-smoothing'] = if @_parent._smooth then 'always' else 'never'
    @_text.canvas.style['-webkit-font-smoothing'] = if @_parent._smooth then 'subpixel-antialiased' else 'none'
    # @_text.canvas.style.position = "absolute";
    # @_text.canvas.style.left = "30px";
    # @_text.canvas.style.top = (800 + (30 * (cc++))) + "px";
    @_text.updateText()
    @_height = @_text.determineFontProperties(@_text.style.font).fontSize + 4
    @_spacer = String.fromCharCode(8202)
    @_spacer_width = @_charWidth(@_spacer)
    @_next = @_charWidth(' ') + @_spacer_width
    return @

  clear: ->
    if @_text?
      @_text.canvas.remove()
      @_text.destroy(true)
      @_text = null
    @_frames = []
    @_realText = ''
    @_next = 0
    @_height = 0
    @_spacer = ''
    @_spacer_width = 0
    return @

  destroy: ->
    # console.log "Destroying #{@toString()}..."
    _.remove(Swim.updates.fonts, @)
    @clear()

  _getFrame: (ch) ->
    if !@_text?
      @_build()
    i = @_realText.indexOf(ch)
    if i != -1 then @_frames[i] else null

  _charWidth: (ch) ->
    @_text.context.measureText(ch).width

  _canCache: (ch) ->
    @_text.texture.baseTexture.width + @_charWidth(ch) + @_spacer_width < @_MAX and @_parent.loaded

  _cacheFrame: (ch) ->
    r = @_getFrame(ch)
    if r? then r else @_addToCache(ch)

  _addToCache: (ch) ->
    if !@_parent.loaded
      return null
    @_realText += ch
    @_text.text += (@_spacer + ch + @_spacer)
    @_text.updateText()
    w = @_charWidth(ch)
    r = new PIXI.Rectangle(Math.ceil(@_next - 1), 0, Math.ceil(w + 1), @_height)
    @_frames.push r
    @_next += @_spacer_width + w + @_spacer_width
    return r

  _cacheTextFrames: (text) ->
    for ch in text
      @_cacheFrame(ch)
    return @

  toString: ->
    "TermFontLine index: #{@_index} frames: #{@_frames.length} next: #{@_next}"
