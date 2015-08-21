{ Plugin, $, path } = Swim

module.exports =

  load: ->
    require('./document.coffee')
    require('./filedocument.coffee')
    require('./remotedocument.coffee')


  unload: ->

    Swim.FileDocument = null
    Swim.RemoteDocument = null
    Swim.Document = null
