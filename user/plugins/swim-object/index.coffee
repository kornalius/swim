{ Plugin, fs, path, cson } = Swim

module.exports =

  load: ->
    Swim.CustomEvent = (detail) -> new CustomEvent '', detail: detail

    Swim.bos = require('bos')
    Swim.qry = require('jsonql')
    Swim.dot = require('dot-object')
    Swim.diff = require('wson-diff')
    Swim.nest = require('nest-object')
    Swim.levn = require('levn')
    Swim.Node = require('tree-node')

    require('./object.coffee')
    require('./number.coffee')
    require('./boolean.coffee')
    require('./string.coffee')
    require('./array.coffee')
    require('./tree.coffee')
    # require('./date.coffee')

    Swim.save = (obj, path, cb) ->
      fs.writeFile path, cson.stringify(obj, null, 2), (err) ->
        throw err if err?
        cb(err) if cb?

    Swim.load = (path, cb) ->
      fs.readFile path, (err, data) ->
        throw err if err?
        cb(err, cson.parse(data)) if cb?

    Swim.saveSync = (obj, path) -> fs.writeFileSync path, cson.stringify(obj, null, 2)

    Swim.loadSync = (path) -> cson.parse(fs.readFileSync path)

    require('./tests/object.test.coffee')
    require('./tests/boolean.test.coffee')
    require('./tests/number.test.coffee')
    require('./tests/string.test.coffee')
    require('./tests/array.test.coffee')
    require('./tests/tree.test.coffee')


  unload: ->

    Swim.bos = null
    Swim.qry = null
    Swim.dot = null
    Swim.diff = null
    Swim.nest = null
    Swim.levn = null
    Swim.Node = null
    Swim.save = null
    Swim.load = null
    Swim.saveSync = null
    Swim.loadSync = null
