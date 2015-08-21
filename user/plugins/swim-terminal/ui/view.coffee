{ Plugin, $, path, Terminal } = Swim

Swim.View = class View extends Terminal

  @::accessor 'rect',
    get: -> @rectangle(@_rect.x, @_rect.y, @_rect.width, @_rect.height)
    set: (value) ->
      if @_rect.x != value.x or @_rect.y != value.y or @_rect.width != value.width or @_rect.height != value.height
        @_pos.x = Math.trunc(value.x / @_charWidth)
        @_pos.y = Math.trunc(value.y / @_charHeight)
        @_size.x = Math.trunc(value.width / @_charWidth)
        @_size.y = Math.trunc(value.height / @_charHeight)
        @_resize()._update()
        # @_resize()
        # @position = @positionInPixels()
        # @_rect = @rectangle(@position.x, @position.y, @widthInPixels(), @heightInPixels())
        # @_update()

  @::accessor 'size',
    get: -> @_size
    set: (value) ->
      if @_size.x != value.x or @_size.y != value.y
        @_size = value.clone()
        @_resize()._update()
        # @_resize()
        # @_rect.width = @widthInPixels()
        # @_rect.height = @heightInPixels()
        # @_update()

  @::accessor 'min',
    get: -> @_min
    set: (value) ->
      if @_min.x != value.x or @_min.y != value.y
        @_min = value.clone()
        @_resize()._update()

  @::accessor 'max',
    get: -> @_max
    set: (value) ->
      if @_max.x != value.x or @_max.y != value.y
        @_max = value.clone()
        @_resize()._update()

  @::accessor 'flex',
    get: -> @_flex
    set: (value) ->
      if !_.deepEqual(@_flex, value)
        @_flex = value.clone()
        @_resize()._update()

  constructor: (config) ->
    if !config?
      config = {}

    if !config.options?
      config.options = {}

    config.options = _.extend {},
      mouseMoveCursor: true
    , config.options

    if !config.cursor?
      config.cursor = {}

    config.cursor = _.extend {},
      visible: false
    , config.cursor

    super config

    if config.contentSize?
      @_contentSize_orig = config.contentSize.clone()
    else
      @_contentSize_orig = null

    @_autosize =
      x: @_size.x == 0
      y: @_size.y == 0

    @_min = if config.min? then config.min.clone() else null
    @_max = if config.max? then config.max.clone() else null

    if config.flex?
      @_flex = config.flex
      # @_flex = _.deepExtend {},
        # layout  : 'vertical' # 'vertical', 'horizontal', 'auto-vertical'
        # wrap    : false # true, 'reverse'
        # self    : 'start' # 'start', 'center', 'end', 'stretch'
        # align   : 'start' # 'start', 'center', 'center-center', 'end'
        # justify : 'start' # 'start', 'center', 'end', 'around', 'full'
        # size    : 'none' # null, true, false, 'none', 'auto', 'one'...'twelve'
        # reverse : false
      # , config.flex
    else
      @_flex = null

    @_div = document.createElement('div')
    @_div._terminal = @
    Swim._layout.appendChild(@_div)

    @_resize()

    @on 'added', (parent) =>
      if @ instanceof View
        @_relayout()

    @_tabIndex = 0

    that = @
    PIXI.ticker.shared.add (time) ->
      if that._div? and (that._div.offsetLeft != that.position.x or that._div.offsetTop != that.position.y or that._div.offsetWidth != that.widthInPixels() or that._div.offsetHeight != that.heightInPixels())
        that.position.x = that._div.offsetLeft
        that.position.y = that._div.offsetTop
        that._size.x = Math.trunc(that._div.offsetWidth / that._charWidth)
        that._size.y = Math.trunc(that._div.offsetHeight / that._charHeight)
        that._rect = that.rectangle(that.position.x, that.position.y, that.widthInPixels(), that.heightInPixels())
        that.clear()

    # @_viewport = if config?.viewport? then config.viewport.clone() else @rectangle(0, 0, @_size.x, @_size.y)
    # @_contentSize = if config?.contentSize? then config.contentSize.clone() else @point(@_size.x, @_size.y)

    setTimeout @render.bind @, 100

  destroy: ->
    Swim._layout.removeChild(@_div)
    @_div = null
    super

  _resize: ->
    @_size.x = if @_autosize.x then @maxLineWidth() else @_size.x
    @_size.y = if @_autosize.y then @viewLines().length else @_size.y
    # if @_min?.x
    #   @_size.x = Math.max(@_min.x, @_size.x)
    # if @_max?.x
    #   @_size.x = Math.min(@_max.x, @_size.x)
    # if @_min?.y
    #   @_size.y = Math.max(@_min.y, @_size.y)
    # if @_max?.y
    #   @_size.y = Math.min(@_max.y, @_size.y)
    @_viewport = @rectangle((if @_viewport? then @_viewport.x else 0), (if @_viewport? then @_viewport.y else 0), @_size.x, @_size.y)
    @_contentSize = if @_contentSize_orig? then @_contentSize_orig else @point(@_size.x, @_size.y)
    @_relayout()
    return @

  _relayout: ->
    @_div.removeAttribute('style')
    @_div.setAttribute('class', '')

    @_div.style.opacity = '.25'
    @_div.style.backgroundColor = 'red'
    @_div.style.pointerEvents = 'none'

    @_div.parentNode.removeChild(@_div)
    if @parent? and @parent._div?
      @parent._div.appendChild(@_div)
    else
      Swim._layout.appendChild(@_div)

    parentFlex = @parent?._flex?.layout?

    if @_flex?.layout?
      switch @_flex.layout
        when true, 'vertical' then @_div.classList.add "vertical"
        when 'auto-vertical' then @_div.classList.add "auto-vertical"
        when 'horizontal' then @_div.classList.add "horizontal"

    if @_flex?.reverse
      @_div.classList.add "reverse"

    if @_flex?.size?
      @_div.classList.add 'flex'
      @_div.classList.add @_flex.size

    if @_flex?.wrap?
      switch @_flex.wrap
        when true then @_div.classList.add 'wrap'
        when 'reverse' then @_div.classList.add 'wrap-reverse'

    if @_flex?.align?
      switch @_flex.align
        when 'start' then @_div.classList.add 'start'
        when 'center' then @_div.classList.add 'center'
        when 'end' then @_div.classList.add 'end'

    if @_flex?.self?
      switch @_flex.self
        when 'start' then @_div.classList.add 'self-start'
        when 'center' then @_div.classList.add 'self-center'
        when 'end' then @_div.classList.add 'self-end'
        when 'stretch' then @_div.classList.add 'self-stretch'

    if @_flex?.justify?
      switch @_flex.justify
        when 'start' then @_div.classList.add 'start-justified'
        when 'center' then @_div.classList.add 'center-justified'
        when 'end' then @_div.classList.add 'end-justified'
        when 'center-center' then @_div.classList.add 'center-justified'; @_div.classList.add 'center-center'
        when 'around' then @_div.classList.add 'around-justified'
        when 'between' then @_div.classList.add 'justified'

    if !parentFlex
      @_div.style.position = 'absolute'
      @_div.style.left = "#{@position.x}px"
      @_div.style.top = "#{@position.y}px"

      # if @parent?
        # @_div.style.margin = "#{@parent.position.y}px 0px 0px #{@parent.position.x}px"

    if @_min?.x?
      @_div.style.minWidth = "#{@_min.x}px"
    if @_min?.y?
      @_div.style.minHeight = "#{@_min.y}px"
    if @_max?.x?
      @_div.style.maxWidth = "#{@_max.x}px"
    if @_max?.y?
      @_div.style.maxHeight = "#{@_max.y}px"

    if @_flex?.size?
      @_div.style.minWidth = "#{@widthInPixels()}px"
      @_div.style.minHeight = "#{@heightInPixels()}px"
    else
      @_div.style.width = "#{@widthInPixels()}px"
      @_div.style.height = "#{@heightInPixels()}px"

    # @position.x = @_div.offsetLeft
    # @position.y = @_div.offsetTop
    # @_size.x = Math.trunc(@_div.offsetWidth / @_charWidth)
    # @_size.y = Math.trunc(@_div.offsetHeight / @_charHeight)
    # @_rect = @rectangle(@position.x, @position.y, @widthInPixels(), @heightInPixels())
    # @clear()
    # @_update()
    return @

  viewLines: -> @viewText().split('\n')

  viewText: -> " "

  maxLineWidth: ->
    m = 0
    for l in @viewLines()
      if l.length > m
        m = l.length
    return m

  fromViewPos: (pos) -> @point(pos.x - @_viewport.x, pos.y - @_viewport.y)

  pointToViewPos: (pos) -> @point(pos.x + @_viewport.x, pos.y + @_viewport.y)

  pixelToViewPos: (pixel) -> @pointToViewPos(@pixelToPos(pixel))

  isValidViewPos: (pos) ->
    pos.x >= 0 and pos.x < @_contentSize.x and pos.y >= 0 and pos.y < @_contentSize.y

  isPosInView: (pos) ->
    pos.x >= @_viewport.x and pos.x <= @_viewport.x + @_viewport.width and pos.y >= @_viewport.y and pos.y <= @_viewport.y + @_viewport.height

  render: ->
    vl = @viewLines()
    ee = Swim.CustomEvent target: @, lines: vl
    @modes_emit 'view.render.begin', ee
    if !ee.defaultPrevented
      pos = @point()
      viewpos = @point()

      vx = @_viewport.x
      vy = @_viewport.y

      to_apply = {}

      for y in [0...@_size.y]
        pos.y = y
        viewpos.y = vy + y

        ee = Swim.CustomEvent target: @, pos: pos, viewpos: viewpos
        @modes_emit 'view.render.line', ee

        if !ee.defaultPrevented
          for x in [0...@_size.x]
            pos.x = x
            viewpos.x = vx + x
            c = @charAt(pos)
            if c?
              if y < vl.length and x < vl[y].length
                to_apply.ch = vl[y][x]
                to_apply.fg = c._fg
                to_apply.bg = c._bg
                to_apply.font = c._font
              else
                to_apply.ch = ' '
                to_apply.fg = @_fg
                to_apply.bg = @_bg
                to_apply.font = @_font

              ee = Swim.CustomEvent target: @, pos: pos, viewpos: viewpos, ch: c, to_apply: to_apply
              @render_char ee if @render_char?
              if !ee.defaultPrevented
                @modes_emit 'view.render.char', ee
                if !ee.defaultPrevented and (c._ch != to_apply.ch or c._fg != to_apply.fg or c._bg != to_apply.bg or c._font != to_apply.font)
                  c.set(to_apply)

      ee = Swim.CustomEvent target: @
      @modes_emit 'view.render.end', ee

    return @

  scrollBy: (pos) ->
    ee = Swim.CustomEvent target: @, pos: pos
    @modes_emit 'view.scrollby', ee
    if !ee.defaultPrevented
      @_viewport.x = Math.min(@_contentSize.x - @_viewport.width, Math.max(0, @_viewport.x + pos.x))
      @_viewport.y = Math.min(@_contentSize.y - @_viewport.height, Math.max(0, @_viewport.y + pos.y))
      @render()._update()

  scrollTo: (pos) ->
    @scrollBy(@point(pos.x - @_viewport.x, pos.y - @_viewport.y))

  scrollInView: (pos, hcenter = false, vcenter = false) ->
    if !pos?
      pos = @point()
    if @isValidViewPos(pos)
      vp = @_viewport.clone()
      if pos.x < vp.x
        vp.x = Math.max(0, pos.x)
      else if pos.x > vp.x + vp.width - 1
        vp.x = Math.min(@_contentSize.x - 1, pos.x - vp.width + 1)
      if pos.y < vp.y
        vp.y = Math.max(0, pos.y)
      else if pos.y > vp.y + vp.height - 1
        vp.y = Math.min(@_contentSize.y - 1, pos.y - vp.height + 1)
      ee = Swim.CustomEvent target: @, viewpos: vp
      @modes_emit 'view.scrollinview', ee
      if !ee.defaultPrevented
        vp = ee.detail.viewpos
        if vp.x != @_viewport.x or vp.y != @_viewport.y
          @scrollTo(vp)

  onDown: (e) =>
    super e

    if !e.defaultPrevented
      if !@_pressed.view?
        @_pressed.view = {}

      vpt = @pointToViewPos(@_pressed.char.pos)

      @_pressed.view.start = vpt.clone()
      @_pressed.view.pos = vpt
      @_pressed.view.distance = 0

      ee = Swim.CustomEvent target: @, event: e
      @modes_emit 'view.mousedown', ee

      if !ee.defaultPrevented and @_options.mouseMoveCursor
        @setCursor(@cursor, @_pressed.char.pos)
        @scrollInView()
        @render()

      if ee.defaultPrevented
        e.preventDefault()

    e.stopPropagation()

  onMove: (e) =>
    super e

    if !e.defaultPrevented and @_pressed?
      @_pressed.view.pos = @pointToViewPos(@_pressed.char.pos)
      vpt = @_pressed.view.pos
      @_pressed.view.distance = vpt.distance(@_pressed.view.start)
      cpt = @pointToViewPos(@cursorPos(@cursor))

      ee = Swim.CustomEvent target: @, event: e
      @modes_emit 'view.mousemove', ee

      if !ee.defaultPrevented and (vpt.y != cpt.y or vpt.x != cpt.x) and @_options.mouseMoveCursor
        @setCursor(@cursor, @_pressed.char.pos)
        @scrollInView()
        @render()

      if ee.defaultPrevented
        e.preventDefault()

      e.stopPropagation()

  onUp: (e) =>
    super e
    if !e.defaultPrevented
      ee = Swim.CustomEvent target: @, event: e
      @modes_emit 'view.mouseup', ee
      if !ee.defaultPrevented
        @scrollInView()
      else
        e.preventDefault()
    e.stopPropagation()

  onOver: (e) =>
    super e
    if !e.defaultPrevented
      ee = Swim.CustomEvent target: @, event: e
      @modes_emit 'view.mouseover', ee
      if ee.defaultPrevented
        e.preventDefault()
    e.stopPropagation()

  onOut: (e) =>
    super e
    if !e.defaultPrevented
      ee = Swim.CustomEvent target: @, event: e
      @modes_emit 'view.mouseout', ee
      if ee.defaultPrevented
        e.preventDefault()
    e.stopPropagation()

  onClick: (e) =>
    super e
    if !e.defaultPrevented
      ee = Swim.CustomEvent target: @, event: e
      @modes_emit 'view.click', ee
      if ee.defaultPrevented
        e.preventDefault()
    e.stopPropagation()

  onDblClick: (e) =>
    super e
    if !e.defaultPrevented
      ee = Swim.CustomEvent target: @, event: e
      @modes_emit 'view.dblclick', ee
      if ee.defaultPrevented
        e.preventDefault()
    e.stopPropagation()

  onScroll: (e) =>
    super e
    if !e.defaultPrevented and @_scrollwheel?.delta?
      ee = Swim.CustomEvent target: @, event: e
      @modes_emit 'view.mousescroll', ee
      if !ee.defaultPrevented
        @scrollBy(@_scrollwheel.delta)
      else
        e.preventDefault()
    e.stopPropagation()
