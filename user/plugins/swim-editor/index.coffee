{ Plugin, $, path } = Swim

module.exports =

  load: ->
    require('./editor.coffee')

    t = new Swim.Editor( text: "Some default text", pos: new PIXI.Point(40, 3), size: new PIXI.Point(30, 1), palette: Swim.palettes.default, charWidth: 11, charHeight: 20, padding: 2, border: { width: 1, fg: 0x888888 }, font: { name: "Glass TTY VT220", size: 20, smooth: true }, cursor: { type: 'caret', wrap: false })

    t.textCursor.moveToLineEnd()
    t.textCursor.insert(", enhanced with power!")

    tt = _.first(Swim.terminals)
    if tt?
      tt.addTerminal(t)
      t.scrollInView()
      t.setFocus()

  unload: ->

    Swim.Editor = null
