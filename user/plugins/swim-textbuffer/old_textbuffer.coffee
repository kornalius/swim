{ Plugin, PIXI, PropertyAccessors } = Swim

Swim.TextBuffer = class TextBuffer

  PropertyAccessors.includeInto(@)

  @::accessor 'text',
    get: -> @getText()
    set: (value) ->
      if @getText() != value
        @setText(value)

  @::accessor 'length', -> @_text.length

  @::accessor 'lines', -> @_lines

  @::accessor 'linesCount', -> @_lines.length

  @::accessor 'modes', -> @_modes

  constructor: (config) ->
    @_lines = []
    @_modes = []
    @setText(config?.text or '')

  destroy: ->
    debugger;
    console.log "Destroying #{@toString()}..."

    @setText('')
    for l in @_lines
      l.destroy()
    @_lines = []

  clear: ->
    @setText('')
    for l in @_lines
      l.destroy()
    @_lines = []
    @_needRebuild = false
    @_update()

  _update: ->
    if @_needRebuild
      if @_needRebuild instanceof TextRange

      @_needRebuild = false
    return @

  lineAt: (row) -> if @isValidRow(row) then @_lines[row] else null

  isValidRow: (row) -> row >= 0 and row < @linesCount

  isValidPos: (pos) ->
    l = @lineAt(pos.row)
    if l?
      pos.col >= 0 and pos.col < l.length
    else
      false

  posToIndex: (pos) -> 0

  indexToPos: (index) -> new TextPos()

  _normalizeIndexArg: (index) ->
    if index instanceof TextPos
      @posToIndex(index)
    else
      index

  _normalizeRangeArg: (fromIndex, toIndex) ->
    if fromIndex instanceof TextRange
      { fromIndex: @posToIndex(fromIndex.start), toIndex: @posToIndex(fromIndex.end) }
    else if _.isArray(fromIndex) and fromIndex.length == 2
      { fromIndex: @_normalizeIndexArg(fromIndex[0]), toIndex: @_normalizeIndexArg(fromIndex[1]) }
    else if _.isObject(fromIndex)
      { fromIndex: @_normalizeIndexArg(fromIndex.fromIndex), toIndex: @_normalizeIndexArg(fromIndex.toIndex) }
    else if fromIndex instanceof TextPos
      if toIndex instanceof TextPos
        toIndex = @posToIndex(toIndex)
      else
        toIndex = @length - 1
      { fromIndex: @posToIndex(fromIndex), toIndex: toIndex }
    else if _.isNumber(fromIndex)
      if toIndex instanceof TextPos
        toIndex = @posToIndex(toIndex)
      else if !_.isNumber(toIndex)
        toIndex = @length - 1
      if fromIndex > toIndex
        fromIndex = toIndex
      if fromIndex < 0
        { fromIndex: @length + fromIndex, toIndex: @length - 1 }
      else
        { fromIndex: fromIndex, toIndex: toIndex }
    else
      { fromIndex: fromIndex, toIndex: toIndex }

  insertText: (index, text) ->
    index = @_normalizeIndexArg(index)
    Swim.UndoRedoManager.save action: 'add', pos: index, data: text
    @_text.splice(index, 0, text)
    @_needRebuild = @indexToPos(index).row
    return @

  deleteText: (fromIndex, toIndex) ->
    { fromIndex, toIndex } = @_normalizeRangeArg(fromIndex, toIndex)
    Swim.UndoRedoManager.save action: 'del', pos: fromIndex, length: toIndex - fromIndex, data: @getText(fromIndex, toIndex)
    @_text.splice(fromIndex, toIndex - fromIndex)
    @_needRebuild = new TextRange(@indexToPos(fromIndex).row, @indexToPos(toIndex).row)
    return @

  setText: (text) ->
    Swim.UndoRedoManager.save action: 'del', pos: 0, length: @length, data: @getText()
    @_text = text
    @_needRebuild = true
    return @

  getText: (fromIndex, toIndex) ->
    { fromIndex, toIndex } = @_normalizeRangeArg(fromIndex, toIndex)
    @_text.substring(fromIndex, toIndex)

  toString: ->
    "TextBuffer"


Swim.TextBufferLine = class TextBufferLine extends TextRange

  PropertyAccessors.includeInto(@)

  @::accessor 'parent',
    get: -> @_parent
    set: (value) ->
      if @_parent != value
        @_parent = value
        @_update()

  @::accessor 'row', -> @_start.row

  constructor: (parent, config) ->
    @_parent = parent
    @_update()

  destroy: ->
    console.log "Destroying #{@toString()}..."
    @_parent = null

  clear: ->
    @_update()

  _update: ->
    return @

  toString: ->
    "TextBufferLine"


Swim.TextPos = class TextPos

  @::accessor 'parent',
    get: -> @_parent
    set: (value) ->
      if @_parent != value
        @_parent = value
        @_update()

  @::accessor 'col',
    get: -> @_col
    set: (value) ->
      if @_col != value
        @_col = value
        @_update()

  @::accessor 'row',
    get: -> @_row
    set: (value) ->
      if @_row != value
        @_row = value
        @_update()

  constructor: (parent, col, row) ->
    @_parent = parent
    @_col = col
    @_row = row

  destroy: ->
    console.log "Destroying #{@toString()}..."
    @_parent = null

  _update: ->
    return @


Swim.TextRange = class TextRange

  @::accessor 'parent',
    get: -> @_parent
    set: (value) ->
      if @_parent != value
        @_parent = value
        @_update()

  @::accessor 'start',
    get: -> @_start
    set: (value) ->
      if @_start != value
        @_start = value
        @_update()

  @::accessor 'end',
    get: -> @_end
    set: (value) ->
      if @_end != value
        @_end = value
        @_update()

  @::accessor 'length',
    get: -> @_end - @_start
    set: (value) ->
      if @_start + value != @_end
        @_end = @_start + value
        @_update()

  constructor: (parent, start, end) ->
    @_parent = parent
    @_start = start
    @_end = end

  destroy: ->
    console.log "Destroying #{@toString()}..."
    @_parent = null

  _update: ->
    return @


Swim.TextBlock = class TextBlock

  @::accessor 'parent',
    get: -> @_parent
    set: (value) ->
      if @_parent != value
        @_parent = value
        @_update()

  @::accessor 'start',
    get: -> @_start
    set: (value) ->
      if @_start != value
        @_start = value
        @_update()

  @::accessor 'end',
    get: -> @_end
    set: (value) ->
      if @_end != value
        @_end = value
        @_update()

  @::accessor 'left',
    get: -> @_start._col
    set: (value) ->
      if @_start._col != value
        @_start.col = value
        @_update()

  @::accessor 'right',
    get: -> @_end._col
    set: (value) ->
      if @_end._col != value
        @_end.col = value
        @_update()

  @::accessor 'top',
    get: -> @_start._row
    set: (value) ->
      if @_start._row != value
        @_start.row = value
        @_update()

  @::accessor 'bottom',
    get: -> @_end._row
    set: (value) ->
      if @_end._row != value
        @_end.row = value
        @_update()

  @::accessor 'width',
    get: -> @_end._col - @_start._col
    set: (value) ->
      if @_start._col + value != @_end._col
        @_end.col = @_start._col + value
        @_update()

  @::accessor 'height',
    get: -> @_end._row - @_start._row
    set: (value) ->
      if @_start._row + value != @_end._row
        @_end.row = @_start._row + value
        @_update()

  constructor: (parent, start, end) ->
    @_parent = parent
    @_start = start
    @_end = end

  destroy: ->
    console.log "Destroying #{@toString()}..."
    @_parent = null

  _update: ->
    return @


Swim.TextHistory = class TextHistory extends Swim.UndoRedoHistory

  exec: (sender, reversed) ->
    super(sender, reversed)

    if reversed
      if @isAdd
        sender.deleteText(@pos, @pos + @length)
      else
        sender.insertText(@pos, @data)
    else
      if @isAdd
        sender.insertText(@pos, @data)
      else
        sender.deleteText(@pos, @pos + @length)

    return @

