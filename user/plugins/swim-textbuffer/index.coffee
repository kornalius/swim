{ Plugin, $, path } = Swim

module.exports =

  load: ->
    require('./textbuffer.coffee')
    require('./textcursor.coffee')

    require('./tests/textbuffer.test.coffee')

  unload: ->

    Swim.TextBuffer = null
    Swim.TextCursor = null
