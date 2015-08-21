{ Plugin, $, path, PropertyAccessors, Terminal, Document } = Swim

Swim.FileDocument = class FileDocument extends Document

  @::accessor 'path',
    get: -> @_path
    set: (value) ->
      if value != @_path
        @_path = value

  constructor: (config) ->
    if !config?
      config = {}
    super config
    @_path = config?.path

  load: (cb) ->
    { fs } = Swim

    if super cb
      fs.readFile @_path, (err, data) ->
        if !err?
          @_terminal.content = data
          @emit 'load', data
          cb(err, data) if cb?
        else
          throw err
          cb(err) if cb?

  save: (cb) ->
    { fs } = Swim

    if super cb
      data = if @_terminal? then @_terminal.content else ""

      fs.writeFile @_path, data, (err) ->
        if err
          throw err
        else
          @emit 'save', data
        cb(err) if cb?
