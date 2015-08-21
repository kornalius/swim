Swim.ANSI = {}

fgcodes = Array.apply(null, new Array(256)).map (_, i) -> '\x1b[38;5;' + i + 'm'
bgcodes = Array.apply(null, new Array(256)).map (_, i) -> '\x1b[48;5;' + i + 'm'

Swim.ANSI =
  colors256: [0x000000, 0x800000, 0x008000, 0x808000, 0x000080, 0x800080, 0x008080, 0xc0c0c0, 0x808080, 0xff0000, 0x00ff00, 0xffff00, 0x0000ff, 0xff00ff, 0x00ffff, 0xffffff, 0x000000, 0x00005f, 0x000087, 0x0000af, 0x0000d7, 0x0000ff, 0x005f00, 0x005f5f, 0x005f87, 0x005faf, 0x005fd7, 0x005fff, 0x008700, 0x00875f, 0x008787, 0x0087af, 0x0087d7, 0x0087ff, 0x00af00, 0x00af5f, 0x00af87, 0x00afaf, 0x00afd7, 0x00afff, 0x00d700, 0x00d75f, 0x00d787, 0x00d7af, 0x00d7d7, 0x00d7ff, 0x00ff00, 0x00ff5f, 0x00ff87, 0x00ffaf, 0x00ffd7, 0x00ffff, 0x5f0000, 0x5f005f, 0x5f0087, 0x5f00af, 0x5f00d7, 0x5f00ff, 0x5f5f00, 0x5f5f5f, 0x5f5f87, 0x5f5faf, 0x5f5fd7, 0x5f5fff, 0x5f8700, 0x5f875f, 0x5f8787, 0x5f87af, 0x5f87d7, 0x5f87ff, 0x5faf00, 0x5faf5f, 0x5faf87, 0x5fafaf, 0x5fafd7, 0x5fafff, 0x5fd700, 0x5fd75f, 0x5fd787, 0x5fd7af, 0x5fd7d7, 0x5fd7ff, 0x5fff00, 0x5fff5f, 0x5fff87, 0x5fffaf, 0x5fffd7, 0x5fffff, 0x870000, 0x87005f, 0x870087, 0x8700af, 0x8700d7, 0x8700ff, 0x875f00, 0x875f5f, 0x875f87, 0x875faf, 0x875fd7, 0x875fff, 0x878700, 0x87875f, 0x878787, 0x8787af, 0x8787d7, 0x8787ff, 0x87af00, 0x87af5f, 0x87af87, 0x87afaf, 0x87afd7, 0x87afff, 0x87d700, 0x87d75f, 0x87d787, 0x87d7af, 0x87d7d7, 0x87d7ff, 0x87ff00, 0x87ff5f, 0x87ff87, 0x87ffaf, 0x87ffd7, 0x87ffff, 0xaf0000, 0xaf005f, 0xaf0087, 0xaf00af, 0xaf00d7, 0xaf00ff, 0xaf5f00, 0xaf5f5f, 0xaf5f87, 0xaf5faf, 0xaf5fd7, 0xaf5fff, 0xaf8700, 0xaf875f, 0xaf8787, 0xaf87af, 0xaf87d7, 0xaf87ff, 0xafaf00, 0xafaf5f, 0xafaf87, 0xafafaf, 0xafafd7, 0xafafff, 0xafd700, 0xafd75f, 0xafd787, 0xafd7af, 0xafd7d7, 0xafd7ff, 0xafff00, 0xafff5f, 0xafff87, 0xafffaf, 0xafffd7, 0xafffff, 0xd70000, 0xd7005f, 0xd70087, 0xd700af, 0xd700d7, 0xd700ff, 0xd75f00, 0xd75f5f, 0xd75f87, 0xd75faf, 0xd75fd7, 0xd75fff, 0xd78700, 0xd7875f, 0xd78787, 0xd787af, 0xd787d7, 0xd787ff, 0xd7af00, 0xd7af5f, 0xd7af87, 0xd7afaf, 0xd7afd7, 0xd7afff, 0xd7d700, 0xd7d75f, 0xd7d787, 0xd7d7af, 0xd7d7d7, 0xd7d7ff, 0xd7ff00, 0xd7ff5f, 0xd7ff87, 0xd7ffaf, 0xd7ffd7, 0xd7ffff, 0xff0000, 0xff005f, 0xff0087, 0xff00af, 0xff00d7, 0xff00ff, 0xff5f00, 0xff5f5f, 0xff5f87, 0xff5faf, 0xff5fd7, 0xff5fff, 0xff8700, 0xff875f, 0xff8787, 0xff87af, 0xff87d7, 0xff87ff, 0xffaf00, 0xffaf5f, 0xffaf87, 0xffafaf, 0xffafd7, 0xffafff, 0xffd700, 0xffd75f, 0xffd787, 0xffd7af, 0xffd7d7, 0xffd7ff, 0xffff00, 0xffff5f, 0xffff87, 0xffffaf, 0xffffd7, 0xffffff, 0x080808, 0x121212, 0x1c1c1c, 0x262626, 0x303030, 0x3a3a3a, 0x444444, 0x4e4e4e, 0x585858, 0x606060, 0x666666, 0x767676, 0x808080, 0x8a8a8a, 0x949494, 0x9e9e9e, 0xa8a8a8, 0xb2b2b2, 0xbcbcbc, 0xc6c6c6, 0xd0d0d0, 0xdadada, 0xe4e4e4, 0xeeeeee]

  getRgb256: (r, g, b) -> Swim.ANSI.colors256[36 * r + 6 * g + b]


  Ansi: class Ansi

    constructor: (terminal) ->
      @_terminal = terminal
      @ATTRIBUTES =
        bold: terminal.bold
        underline: terminal.underline
        italic: terminal.italic
        foreground: terminal.fg
        background: terminal.bg
        conceal: terminal.conceal
        strike: terminal.strike
        reverse: terminal.reverse
      @_attrs = {}
      @_foreground = 0
      @_background = 0
      @reset()

    write: (value) ->

      if @_foreground > 1
        @set('foreground', @_terminal.color256FromIndex(value))
        @_foreground = 0
        return @

      if @_background > 1
        @set('background', @_terminal.color256FromIndex(value))
        @_background = 0
        return @

      if value == 5
        if @_foreground == 1
          @_foreground = 2
          return @
        else if @_background == 1
          @_background = 2
          return @

      switch value

        when 0 then @reset()
        when 1 then @set('bold', true)
        when 3 then @set('italic', true)
        when 4 then @set('underline', true)
        when 7 then @set('reverse', true)
        when 8 then @set('conceal', true)
        when 9 then @set('strike', true)

        when 21 then @reset('bold')
        when 22 then @reset('bold')
        when 23 then @reset('italic')
        when 24 then @reset('underline')
        when 27 then @reset('reverse')
        when 28 then @reset('conceal')
        when 29 then @reset('strike')

        when 38 then @_foreground = 1
        when 39 then @reset('foreground')
        when 48 then @_background = 1
        when 49 then @reset('background')

        else
          if value >= 30 and value <= 37
            this.set('foreground', @_terminal.colorFromIndex(value - 30))
          else if value >= 40 and value <= 47
            this.set('background', @_terminal.colorFromIndex(value - 40))
          else if value >= 90 and value <= 97
            this.set('foreground', @_terminal.colorFromIndex(value - 82))
          else if value >= 100 and value <= 107
            this.set('background', @_terminal.colorFromIndex(value - 92))

      return @

    set: (attr, value) ->
      @_attrs[attr] = value
      return @

    reset: (attr) ->
      if attr?
        @_attrs[attr] = @ATTRIBUTES[attr]
      else
        @_attrs = _.clone(@ATTRIBUTES)
      return @

    attrs: ->
      output = {}
      _.each(@ATTRIBUTES, (defaultVal, attr) ->
        value = @_attrs[attr]
        if value != defaultVal
          output[attr] = value
      , @)
      if output.reverse
        output.foreground = @_attrs.background
        output.background = @_attrs.foreground
      return output


  Parser: class Parser

    constructor: ->
      @tokens = [
        # SGR escape codes
        [ /^\x1b\[(?:\d{0,3};?)+m/, @replaceAnsi ]
        # All other escape codes
        [ /^\x1b\[[^@-~]*[@-~]/, @replaceOtherAnsi ]
        # Replace ^[ chars
        [ /^\x1b([@-~])/, @replaceEscape ]
        # Replace Ctrl+? chars
        [ /^([\x01-\x1a])/, @replaceCtrl ]
        # Keep actual text
        [ /^([^\x01-\x1b]+)/m, @replaceText ]
      ]

    getNumbers: (string) ->
      _.map(string.match(/\d+/g), (number) ->
        parseInt(number, 10)
      )

    replaceAnsi: (codes) ->
      codes = @getNumbers(codes)
      if !codes.length
        codes = [0]
      { type: 'ansi', value: codes }

    replaceOtherAnsi: (codes) ->
      code = _.last(codes)
      codes = @getNumbers(codes)
      if !codes.length
        codes = [0]
      { type: 'ansi-other', code: code, value: codes }

    replaceCtrl: (code) ->
      { type: 'ctrl', value: code }

    replaceEscape: (code) ->
      { type: 'esc', value: code }

    replaceText: (text) ->
      { type: 'text', value: text }

    process: (fn, output) ->
      that = @
      (match) ->
        output.push(fn.call(that, match))
        return ''

    write: (input) ->
      output = []
      while (len = input.length) > 0
        for i in [0...@tokens.length]
          token = @tokens[i]
          if token[0].test(input)
            input = input.replace(token[0], @process(token[1], output))
            break
        if input.length == len
          break
      return output

  decode: (text) ->
    if !Swim.ANSI._parser?
      Swim.ANSI._parser = new Swim.ANSI.Parser()
    Swim.ANSI._parser.write(text)

  ansi_to_swim: (terminal, text) ->
    ansi = Swim.ANSI.decode(text)

    _state = new Swim.ANSI.Ansi(terminal)

    for cmd in ansi

      switch cmd.type

        when 'text'
          terminal._write(cmd.value)

        when 'ansi'
          for value in cmd.value
            _state.write(value)

          attrs = _state._attrs

          terminal.fg = attrs.foreground
          terminal.bg = attrs.background
          terminal.bold = attrs.bold
          terminal.italic = attrs.italic
          terminal.underline = attrs.underline
          terminal.strike = attrs.strike
          terminal.conceal = attrs.conceal
          terminal.reverse = attrs.reverse

        when 'ansi-other'
          switch cmd.code

            when 'A'
              for i in [0..cmd.value[0]]
                terminal.up

            when 'B'
              for i in [0..cmd.value[0]]
                terminal.down

            when 'C'
              for i in [0..cmd.value[0]]
                terminal.right

            when 'D'
              for i in [0..cmd.value[0]]
                terminal.left

            when 'E'
              terminal.bol
              for i in [0..cmd.value[0]]
                terminal.down

            when 'F'
              terminal.bol
              for i in [0..cmd.value[0]]
                terminal.up

            when 'G'
              for c in terminal._cursors
                c.moveTo(terminal.point(cmd.value[0], c.pos.y))

            when 'H', 'f'
              terminal.setCursor(terminal.point(cmd.value[1], cmd.value[0]))

            when 'J'
              switch cmd.value[0]
                when 0 then terminal.kend
                when 1 then terminal.khome
                when 2
                  terminal.cls
                  terminal.home

            when 'K'
              switch cmd.value[0]
                when 0 then terminal.keol
                when 1 then terminal.kbol
                when 2
                  terminal.bol.kline

            when 'L'
              for c in terminal._cursors
                terminal.insertRow(c.pos.y - 1, cmd.value[0])

            when 'M'
              for c in terminal._cursors
                terminal.deleteRow(c.pos.y, cmd.value[0])

            when 'S'
              terminal.scrollBy(terminal.point(0, -cmd.value[0]))

            when 'T'
              terminal.scrollBy(terminal.point(0, cmd.value[0]))

            when 'X'
              p = terminal._tmpPt
              for c in terminal._cursors
                p.x = c.pos.x
                p.y = c.pos.y
                for x in [c.pos.x...terminal._size.x]
                  terminal.eraseAt(p)
                  p.x++

            when 's'
              terminal.scur

            when 'u'
              terminal.rcur

            when 'h'
              if cmd.value[0] == 7
                c._wrap = cmd.value[1] for c in terminal._cursors
              else if cmd.value[0] == 25
                c.hide() for c in terminal._cursors

            when 'l'
              if cmd.value[0] == 7
                c._wrap = -1 for c in terminal._cursors
              else if cmd.value[0] == 25
                c.show() for c in terminal._cursors

        when 'esc'
          switch cmd.value
            when 'E' then terminal.cr
            when 'H' then terminal.tab

        when 'ctrl'
          switch cmd.value
            when '\x07' then terminal.bell
            when '\x08' then terminal.bs
            when '\x09' then terminal.tab
            when '\x0A'
              if Swim.IS_OSX or Swim.IS_LINUX
                terminal.cr
              else
                terminal.lf
            when '\x0B' then terminal.lf.tab
            when '\x0D' then terminal.cr
            when '\x7F' then terminal.del

