{ Plugin, $, path } = Swim

module.exports =

  load: ->

    Swim.loadCSS = (path, macros) ->
      fs = require('fs')
      el = document.createElement('style')
      s = fs.readFileSync(path).toString()
      if macros?
        for k, v of macros
          s = s.replace(new RegExp('__' + k + '__', 'gim'), v)
      el.textContent = s
      document.querySelector('head').appendChild(el)
      return el

    Swim.loadCSS(path.join(__dirname, 'flex.css'))

    require('./palettes.coffee')
    require('./fonts.coffee')
    require('./cursor.coffee')
    require('./terminal.coffee')

    require('./converters/ansi.coffee')
    require('./converters/html.coffee')

    require('./ui/view.coffee')
    require('./ui/textview.coffee')
    require('./ui/listview.coffee')
    require('./ui/checkbox.coffee')

    Swim._layout = document.createElement('div')
    Swim._layout.style.display = 'block'
    Swim._layout.style.position = 'fixed'
    Swim._layout.style.left = '0px'
    Swim._layout.style.right = '0px'
    Swim._layout.style.top = '0px'
    Swim._layout.style.bottom = '0px'
    Swim._layout.style.pointerEvents = 'none'
    Swim._layout.style.backgroundColor = 'rgba(0, 100, 0, .05)'
    document.body.appendChild(Swim._layout)

    Swim.Keys = Keys = require 'combokeys'

    globalKeys = new Swim.Keys(document.documentElement)

    # globalKeys.bind 'any-character', (e) ->
    #   console.log e

    Swim.icons = Swim.loadSync(path.join(__dirname, "icons.cson"))
    Swim.iconFont = Swim.getFont(path: './fonts/ico.ttf', name: "ico", size: 19)

    require('./update.coffee')

    require('./tests/terminal/terminal.test.coffee')

    require('./tests/ui/textview.test.coffee')
    require('./tests/ui/listview.test.coffee')
    require('./tests/ui/checkbox.test.coffee')
    require('./tests/ui/flex.test.coffee')


  unload: ->
    for t in Swim.terminals
      t.destroy()

    for f in Swim.fonts
      f.destroy()

    Swim.TextView = null
    Swim.ListView = null
    Swim.Checkbox = null
    Swim.View = null

    Swim.terminals = null
    Swim.fonts = null
    Swim.key = null
    Swim.Keys = null
    Swim.updates = null
    Swim.Terminal = null
    Swim.TermChar = null
    Swim.TermFont = null
    Swim.TermFontLine = null
    Swim.TermCursor = null
    Swim.palettes = null
    Swim.ANSI = null

    Swim._layout.parentNode.removeChild(Swim._layout)
    Swim._layout = null
    Swim.loadCSS = null

