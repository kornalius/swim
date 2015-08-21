{ Plugin, $, path } = Swim

module.exports =

  load: ->
    Swim.Textlex = require('textlex')
    Swim.lexer = new Swim.Textlex()

    require('./tests/textlex.test.coffee')


  unload: ->

    Swim.lexer = null
    Swim.Textlex = null
