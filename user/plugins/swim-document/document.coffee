{ Plugin, $, path, PropertyAccessors, Terminal, EventEmitter } = Swim

Swim.Document = class Document extends EventEmitter

  PropertyAccessors.includeInto(@)

  @::accessor 'terminal', -> @_terminal

  @::accessor 'options',
    get: -> @_options
    set: (value) ->
      @_options = value

  constructor: (terminal, config) ->
    EventEmitter @

    @_terminal = terminal

    if !config?
      config = {}

    _.extend @_options,
      readonly: false
      modified: false

    if config?.options?
      _.extend(@_options, config.options)

    @_modes = []

  modes_emit: (e) ->
    for m in @_modes
      m.emit e
      if e.defaultPrevented
        break

  isReadOnly: ->
    ee = Swim.CustomEvent target: @, readonly: @_options.readonly
    @modes_emit 'document.readonly', ee
    ee.detail.readonly

  isModified: ->
    ee = Swim.CustomEvent target: @, modified: @_options.modified
    @modes_emit 'document.modified', ee
    ee.detail.modified

  load: (cb) ->
    ee = Swim.CustomEvent target: @
    @modes_emit 'document.load', ee
    if !ee.defaultPrevented
      @_options.modified = false
      ee = Swim.CustomEvent target: @
      @modes_emit 'document.loaded', ee
      return true
    else
      return false

  save: (cb) ->
    ee = Swim.CustomEvent target: @
    @modes_emit 'document.save', ee
    if !ee.defaultPrevented
      @_options.modified = false
      ee = Swim.CustomEvent target: @
      @modes_emit 'document.saved', ee
      return true
    else
      return false
