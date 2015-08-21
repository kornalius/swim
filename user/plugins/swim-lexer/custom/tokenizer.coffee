{ Plugin, $, path, PropertyAccessors } = Swim

Swim.Tokenizer = class Tokenizer

    PropertyAccessors.includeInto(@)

    @::accessor 'tokens', -> @_tokens

    @::accessor 'types', -> @_types

    constructor: ->

      @_types =
        SYMBOL     : '@'
        SEPARATOR  : '|'
        CONSTANT   : 'C'
        IDENTIFIER : 'I'
        WHITESPACE : ' '
        NEWLINE    : '/'
        STRING     : '"'
        COMMENT    : '#'

      @_symbols = "~!@#$%^&*_+-=|:?."
      @_separators = '()<>{}[],;'

      @_digits = '0123456789'
      @_letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
      @_hex_letters = 'ABCDEFabcdef'

      @identifier = @_letters + '_'
      @_alt_identifier = @identifier + @_digit
      @_whitespace = ' \t\v'
      @_int = @_digits
      @_hex = @_digits + @_hex_letters
      @_float = @_digits
      @_alt_float = @_float + '.+Ee'
      @_string = '\'"'
      @_newline = '\n\r\f'

      @_rules = {}
      @_rules[@_whitespace] = @scan_whitespaces
      @_rules[@_newline] = @scan_newlines
      @_rules[@_separators] = @scan_separators
      @_rules[@_symbols] = @scan_symbols
      @_rules[@_digits] = @scan_digits
      @_rules[@identifier] = @scan_identifier
      @_rules[@_string] = @scan_string

      @_skips =
        WHITESPACE : true
        NEWLINE    : true
        COMMENT    : true
        CONSTANT   : false
        IDENTIFIER : false
        SYMBOL     : false
        SEPARATOR  : false
        STRING     : false

      @reset()

    reset: ->
      @_tokens = []
      @_i = 0
      @_len = 0
      @_line_start = 0
      @_prev_i = 0
      @_row = 1

    tokenInfo: (token) -> "'#{token.value}' (#{token.type}) (#{token.col}, #{token.row}) ##{token.i} #{token.path}"

    error: (msg) -> throw new Error("#{msg} at #{@_tokens[@_i]}")

    addToken: (config) ->
      _.extend(config, i: @_prev_i, col: @_prev_i - @_line_start + 1, row: @_row, path: @_path)
      @_tokens.push config

    char: (i) ->
      if !i?
        i = @_i
      if i in [0...@_len]
        return @_text[i]
      else
        return null

    peek: (skip = 1) -> @char(@_i + skip)

    next: (count = 1) ->
      while count
        @_i++
        count--
      @char(@_i)

    scan_whitespaces: ->
      w = ''
      c = @char()
      while c in @_whitespace
        w += c
        c = @next()
      if !@_skips.WHITESPACE
        @addToken(value: w, type: @_types.WHITESPACE)

    scan_newlines: ->
      w = ''
      c = @char()
      while c in @_newline
        w += c
        @_rows++
        @_col = 0
        c = @next()
      if !@_skips.NEWLINE
        @addToken(value: w, type: @_types.NEWLINE)

    scan_symbols: ->
      w = ''
      c = @char()
      while c in @_symbols
        w += c
        c = @next()
      if !@_skips.SYMBOL
        @addToken(value: w, type: @_types.SYMBOL)

    scan_separators: ->
      c = @char()
      while c in @_separators
        if !@_skips.SEPARATOR
          @addToken(value: c, type: @_types.SYMBOL)
        c = @next()

    scan_identifier: ->
      w = ''
      c = @char()
      while c in @_alt_identifier
        w += c
        c = @next()
      @addToken(value: w, type: @_types.IDENTIFIER)

    scan_hex: ->
      if @char() == '0' and @peek() == 'x'
        w = ''
        c = @char()
        while @_i < @_len
          if !(c in @_hex)
            break
          w += c
          c = @next()
        if !@_skips.CONSTANT
          @addToken(value: w, type: @_types.CONSTANT)
        return true
      else
        return false

    scan_octal: -> false

    scan_float: ->
      w = ''
      ii = @_i
      c = @char()
      while @_i < @_len
        if !(c in @_alt_float)
          break
        w += c
        c = @next()
      if !@_skips.CONSTANT
        @addToken(value: w, type: @_types.CONSTANT)
      return true

    scan_int: ->
      w = ''
      ii = @_i
      while ii < @_len
        c = @peek(ii++)
        return false if c == '.'
      c = @char()
      while @_i < @_len
        if !(c in @_int)
          break
        w += c
        c = @next()
      if !@_skips.CONSTANT
        @addToken(value: w, type: @_types.CONSTANT)
      return true

    scan_digits: ->
      if !@scan_hex()
        if !@scan_octal()
          if !@scan_int()
            return @scan_float()

    scan_string: ->
      w = @char()
      c = @next()
      while @_i < @_len
        if c in @_string
          w += c
          c = @next()
          break
        if c == '\\'
          c = @next()
        w += c
        c = @next()
      if !@_skips.STRING
        @addToken(value: w, type: @_types.STRING)

    scan_comment: ->
      w = ''
      c = @char()
      while @_i < @_len
        if !(c in @_comment)
          break
        w += c
        c = @next()
      if !@_skips.COMMENT
        @addToken(value: w, type: @_types.COMMENT)

    scan: (text, path, i = 0) ->
      @reset()
      @_text = text
      @_path = path
      @_len = text.length
      @_i = i

      # find current line number and it's starting index
      x = 0
      lines = text.split('\n')
      for l in lines
        if x + l.length + 1 >= i
          @_line_start = x
          break
        x += l.length + 1
        @_row++

      while @_i < @_len
        found = false

        @_prev_i = @_i

        c = @char()

        for k, fn of @_rules
          if c in k and fn?
            found = true
            fn.call @
            break

        if !found
          @error("Syntax error")

      return @_tokens