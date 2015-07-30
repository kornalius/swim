sysPath = ->
  require('path').join(Swim.dirs.module, 'settings.cson')


userPath = ->
  require('path').join(Swim.dirs.user, 'settings.cson')


module.exports =

  load: (cb) ->
    { fs, path, cson } = Swim
    Swim.settings.system = {}

    console.log "Loading settings..."
    console.log "  system #{sysPath()}..."
    fs.readFile sysPath(), (err, data) ->
      if !err?
        if data.length
          Swim.settings.system = cson.parse(data)
        else
          Swim.settings.system = {}

        console.log "  user #{userPath()}..."
        fs.readFile userPath(), (err, data) ->
          if !err?
            if data.length
              Swim.settings.user = cson.parse(data)
            else
              Swim.settings.user = {}
          else
            throw err
          cb(err) if cb?
      else
        throw err
        cb(err) if cb?


  save: (cb) ->
    { cson } = Swim
    console.log "Saving settings..."
    console.log "  user"
    if Swim.settings? and Swim.settings.user?
      require('fs').writeFile userPath(), cson.stringify(Swim.settings.user, null, 2), (err) ->
        cb(err) if cb?


  saveSync: ->
    { cson } = Swim
    console.log "Saving settings (sync)..."
    console.log "  user"
    if Swim.settings? and Swim.settings.user?
      require('fs').writeFileSync userPath(), cson.stringify(Swim.settings.user, null, 2)


  set: (key, value, autosave=false) ->
    _.setValueForKeyPath Swim.settings.user, key, value
    if autosave
      @save()


  get: (key, defaultValue) ->
    _.valueForKeyPath _.extend({}, Swim.settings.system, Swim.settings.user), key

