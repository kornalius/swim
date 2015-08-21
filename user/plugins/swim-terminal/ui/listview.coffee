{ Plugin, $, path, Terminal, TermCursor, View } = Swim

Swim.ListView = class ListView extends View

  @::accessor 'items',
    get: ->  @_items
    set: (value) ->
      if @_items != value
        @_items = value
        @_contentSize.x = @maxLineWidth()
        @_contentSize.y = @_items.length
        @_update()

  @::accessor 'selections',
    get: ->  @_selections
    set: (value) ->
      if @_selections != value
        @_selections = value
        @_update()

  constructor: (config) ->
    if !config?
      config = {}

    if !config.options?
      config.options = {}

    config.options = _.extend {},
      selFg: 0xFFFFFF
      selBg: 0x496D90
      scrollable:
        x: false
        y: true
    , config.options

    if !config.cursor?
      config.cursor = {}

    super config

    @selections = []
    @items = if config?.items? then config.items else []
    @_document = if config?.document? then config.document else null

    @bindkey ['mod+c', 'mod+x', 'mod+v', 'mod+z', 'mod+shift+z'], (e) => e.preventDefault()

    @bindkey 'up', (e) =>
      @scrollInView()
      e.stopPropagation()

    @bindkey 'down', (e) =>
      @_selections = [@_pressed.view.pos.y]
      @setCursor(@cursor, )
      @scrollInView()
      e.stopPropagation()

    @bindkey 'pgup', (e) =>
      @scrollInView()
      e.stopPropagation()

    @bindkey 'pgdown', (e) =>
      @scrollInView()
      e.stopPropagation()

    @bindkey ['home', 'command+left'], (e) =>
      @scrollInView()
      e.stopPropagation()

    @bindkey ['end', 'command+right'], (e) =>
      @scrollInView()
      e.stopPropagation()

  getWidth: -> if @_size.x == -1 then @maxLineWidth() else @_size.x

  getHeight: -> if @_size.y == -1 then @viewLines().length else @_size.y

  viewLines: ->
    if !@_items?
      return []
    lines = []
    lc = @_items.length
    for y in [@_viewport.y..@_viewport.y + @_viewport.height]
      if y < lc
        lines.push @_items[y]
    ee = Swim.CustomEvent target: @, lines: lines
    @modes_emit 'list.lines', ee
    return lines

  viewText: -> @viewLines().join("\n")

  maxLineWidth: ->
    m = 0
    for l in @_items
      if l.length > m
        m = l.length
    ee = Swim.CustomEvent target: @, width: m
    @modes_emit 'list.maxLineWidth', ee
    if !ee.defaultPrevented
      m = ee.detail.width
    return m

  render_char: (e) =>
    d = e.detail
    sel = @isIndexSelected(d.viewpos.y)
    if sel
      d.to_apply.fg = @_options.selFg
      d.to_apply.bg = @_options.selBg
    else
      d.to_apply.fg = @_fg
      d.to_apply.bg = @_bg

  isIndexSelected: (index) -> @_selections.indexOf(index) != -1

  isItemSelected: (item) ->
    i = @_items.indexOf(item)
    if i != -1 then @isIndexSelected(i) else false

  selectIndex: (index) ->
    if !@isIndexSelected(index)
      @_selections.push(index)
    return @

  selectItem: (item) ->
    i = @_items.indexOf(item)
    if i != -1
      @selectIndex(i)
    return @

  unselectIndex: (index) ->
    if @isIndexSelected(index)
      _.remove(@_selections, index)
    return @

  unselectItem: (item) ->
    i = @_items.indexOf(item)
    if i != -1
      @unselectIndex(i)
    return @

  scrollInView: (pos, hcenter = false, vcenter = false) ->
    if !pos?
      pos = @cursor.pos
    super pos, hcenter, vcenter

  onDown: (e) =>
    super e
    @_selections = [@_pressed.view.pos.y]
    @render()
    e.stopPropagation()

  onMove: (e) =>
    super e
    if @_pressed?
      @_selections = [@_pressed.view.pos.y]
      @render()
      e.stopPropagation()
