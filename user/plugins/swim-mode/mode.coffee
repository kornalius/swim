{ Plugin, $, path, PropertyAccessors, Terminal, EventEmitter } = Swim

Swim.Mode = class Mode extends EventEmitter

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

    if config?.options?
      _.extend(@_options, config.options)

  attached: ->

  detached: ->
    @_keys.detach()
    @_keys = null

  bindkey: (sequence, callback) ->
    if !@_keys?
      @_keys = new Swim.Keys(document.documentElement)

    ee = Swim.CustomEvent target: @, sequence: sequence
    @modes_emit 'mode.keybind', ee
    if !ee.defaultPrevented
      fn = ((e) ->
        if @focused
          ee = Swim.CustomEvent target: @
          @modes_emit sequence, ee
          if !ee.defaultPrevented
            callback.apply(@, arguments)
          e.stopPropagation()
      ).bind @_terminal

      @_keys.bind.call(@_keys, sequence, fn)
