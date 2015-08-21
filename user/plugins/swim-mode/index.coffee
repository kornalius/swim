{ Plugin, $, path } = Swim

module.exports =

  load: ->
    require('./mode.coffee')


  unload: ->

    Swim.Mode = null
