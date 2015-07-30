{ Plugin, PIXI, PropertyAccessors } = Swim

Swim.TermCursor = class TermCursor

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
      if @_pos.x != value.x or @_pos.y != value.y
        @_pos = value.clone()
        @_update()

  @::accessor 'bg',
    get: -> @_bg
    set: (value) ->
      if @_bg != value
        @_bg = value
        @_update()

  @::accessor 'visible',
    get: -> @_visible
    set: (value) ->
      if @_visible != value
        @_visible = value
        @_state =
          visible: value
        @_update()

  @::accessor 'width',
    get: -> @_width
    set: (value) ->
      if @_width != value
        @_width = value
        @_update()

  @::accessor 'height',
    get: -> @_height
    set: (value) ->
      if @_height != value
        @_height = value
        @_update()

  @::accessor 'offset',
    get: -> @_offset
    set: (value) ->
      if @_offset.x != value.x or @_offset.y != value.y
        @_offset = value
        @_update()

  @::accessor 'wrap',
    get: -> @_wrap
    set: (value) ->
      if @_wrap != value
        @_wrap = value

  @::accessor 'type',
    get: -> @_type
    set: (value) ->
      if @_type != value
        @_type = value
        @_update()

  constructor: (terminal, config) ->
    @_terminal = terminal
    @_pos = if config?.pos? then config.pos.clone() else new PIXI.Point()
    @_bg = config?.color or @_terminal._palette.fg
    @_visible = config?.visible != false
    @_width = config?.width or @_terminal._charWidth
    @_height = config?.height or @_terminal._charHeight
    @_wrap = config?.wrap != false
    @_type = config?.type or 'block'
    @_offset = if config?.offset? then config.offset.clone() else new PIXI.Point()
    @_state =
      visible: @_visible
    @_sprite = null
    @_update()

  destroy: ->
    console.log "Destroying #{@toString()}..."
    Swim.updates.delCursor @

  _update: ->
    Swim.updates.addCursor @
    return @

  _inBounds: (pos) ->
    pos.x >= 0 and pos.x < @_terminal._size.x and pos.y >= 0 and pos.y < @_terminal._size.y

  _bound: (pos) ->
    if @_wrap
      if pos.x < 0
        if pos.y > 0
          pos.x = @_terminal._size.x - 1 + pos.x
          pos.y--
        else
          pos.x = 0
      else if pos.x > @_terminal._size.x - 1
        if pos.y >= @_terminal._size.y - 1
          pos.x = @_terminal._size.x - 1
        else
          pos.x = 0
          pos.y++

      if pos.y < 0
        pos.y = 0
      else if pos.y > @_terminal._size.y - 1
        pos.y = @_terminal._size.y - 1

    return pos

  moveTo: (pos) ->
    @_pos = @_bound(pos).clone()
    @_terminal._prevBlink = 0
    @_update()

  moveBy: (pos) ->
    pos.x += @_pos.x
    pos.y += @_pos.y
    @moveTo(pos)

  reset: -> @_state.visible = @_visible; @_terminal._prevBlink = Date.now(); @

  home: -> @moveTo(new PIXI.Point(0, 0))

  end: -> @moveTo(new PIXI.Point(@_terminal._size.x - 1, @_terminal._size.y - 1))

  bol: -> @moveTo(new PIXI.Point(0, @_pos.y))

  eol: -> @moveTo(new PIXI.Point(@_terminal._size.x - 1, @_pos.y))

  cr: -> @down().bol()

  isBol: -> @_pos.x == 0

  isEol: -> @_pos.x == @_terminal._size.x - 1

  isHome: -> @isBol() and @_pos.y == 0

  isEnd: -> @isEol() and @_pos.y == @_terminal._size.y - 1

  left: (count) ->
    if !count?
      count = 1
    @moveBy(new PIXI.Point(-count, 0))
    return @

  right: (count) ->
    if !count?
      count = 1
    @moveBy(new PIXI.Point(count, 0))
    return @

  up: (count) ->
    if !count?
      count = 1
    @moveBy(new PIXI.Point(0, -count))
    return @

  down: (count) ->
    if !count?
      count = 1
    @moveBy(new PIXI.Point(0, count))
    return @

  toString: ->
    "Cursor (#{@_pos.x}, #{@_pos.y})"
