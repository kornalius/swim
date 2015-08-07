{ Plugin, $, path, PropertyAccessors, Terminal, Document } = Swim

Swim.RemoteDocument = class RemoteDocument extends Document

  @::accessor 'url',
    get: -> @_url
    set: (value) ->
      if value != @_url
        @_url = value

  constructor: (config) ->
    if !config?
      config = {}
    super config
    @_url = config?.url

  load: (cb) ->
    super cb

  save: (cb) ->
    super cb
