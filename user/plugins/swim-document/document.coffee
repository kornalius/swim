{ Plugin, $, path, PropertyAccessors, Terminal, EventEmitter } = Swim

Swim.Document = class Document

  PropertyAccessors.includeInto(@)

  @::accessor 'terminal', -> @_terminal

  @::accessor 'options',
    get: -> @_options
    set: (value) ->
      @_options = value

  constructor: (config) ->
    EventEmitter @

    if !config?
      config = {}

    _.extend @_options,
      readonly: false
      modified: false

    if config?.options?
      _.extend(@_options, config.options)

    @_terminal = config?.terminal
    @_modes = []

  isReadOnly: ->
    @_options.readonly

  isModified: ->
    @_options.modified

  load: (cb) ->
    @_options.modified = false
    return @

  save: (cb) ->
    @_options.modified = false
    return @
