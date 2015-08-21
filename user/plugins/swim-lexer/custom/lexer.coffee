{ Plugin, $, path, Tokenizer, PropertyAccessors } = Swim

# Swim.Lexer =

#   parse: (text, path, config) ->
#     p = new Swim.Lexer.Parser(config)
#     p.parse(text, path)
#     for l in p.lexemes
#       console.log Swim.Lexer.lexemeInfo(l)
#     return p.lexemes

#   lexemeInfo: (lexeme) ->
#     tokens = []
#     for t in lexeme.tokens
#       tokens.push Swin.Tokenizer.tokenInfo(t)
#     "'#{lexeme.rule}' [#{tokens.join(' : ')}]"

Swim.Lexer = class Lexer

    PropertyAccessors.includeInto(@)

    @::accessor 'token', -> @_tokens[@_current]

    @::accessor 'tokens', -> @_tokens

    @::accessor 'current', -> @_current

    @::accessor 'prev', -> @_prev

    @::accessor 'lexemes', -> @_lexemes

    constructor: ->
      @_lexemes = []
      @_current = 0
      @_tokens = []
      @_reserved = []

      @add_symbol_alias 'LPAREN'       , '('
      @add_symbol_alias 'RPAREN'       , ')'
      @add_symbol_alias 'LBRACK'       , '['
      @add_symbol_alias 'RBRACK'       , ']'
      @add_symbol_alias 'LBRACE'       , '{'
      @add_symbol_alias 'RBRACE'       , '}'
      @add_symbol_alias 'DOT'          , '.'
      @add_symbol_alias 'COMMA'        , ','
      @add_symbol_alias 'COLON'        , ':'
      @add_symbol_alias 'SEMICOLON'    , ';'
      @add_symbol_alias 'ELLIPSIS'     , '...'
      @add_symbol_alias 'RIGHT_ASSIGN' , '>>='
      @add_symbol_alias 'LEFT_ASSIGN'  , '<<='
      @add_symbol_alias 'ADD_ASSIGN'   , '+='
      @add_symbol_alias 'SUB_ASSIGN'   , '-='
      @add_symbol_alias 'MUL_ASSIGN'   , '*='
      @add_symbol_alias 'DIV_ASSIGN'   , '/='
      @add_symbol_alias 'MOD_ASSIGN'   , '%='
      @add_symbol_alias 'AND_ASSIGN'   , '&='
      @add_symbol_alias 'XOR_ASSIGN'   , '^='
      @add_symbol_alias 'OR_ASSIGN'    , '|='
      @add_symbol_alias 'RIGHT_OP'     , '>>'
      @add_symbol_alias 'LEFT_OP'      , '<<'
      @add_symbol_alias 'INC_OP'       , '++'
      @add_symbol_alias 'DEC_OP'       , '--'
      @add_symbol_alias 'PTR_OP'       , '->'
      @add_symbol_alias 'LE_OP'        , '<='
      @add_symbol_alias 'GE_OP'        , '>='
      @add_symbol_alias 'EQ_OP'        , '=='
      @add_symbol_alias 'NE_OP'        , '!='
      @add_symbol_alias 'LT_OP'        , '<'
      @add_symbol_alias 'GT_OP'        , '>'
      @add_symbol_alias 'NEG_OP'       , '!'
      @add_symbol_alias 'ADD_OP'       , '+'
      @add_symbol_alias 'SUB_OP'       , '-'
      @add_symbol_alias 'MUL_OP'       , '*'
      @add_symbol_alias 'DIV_OP'       , '/'
      @add_symbol_alias 'MOD_OP'       , '%'
      @add_symbol_alias 'BIT_AND'      , '&'
      @add_symbol_alias 'BIT_OR'       , '|'
      @add_symbol_alias 'BIT_XOR'      , '^'
      @add_symbol_alias 'AND_OP'       , '&&'
      @add_symbol_alias 'OR_OP'        , '||'
      @add_symbol_alias 'TILDE'        , '~'
      @add_symbol_alias 'QMARK'        , '?'
      @add_symbol_alias 'ASSIGN'       , '='

    add_symbol_alias: (name, symbol) -> @__proto__.accessor "_#{name.toUpperCase()}_", -> @_SYMBOL(symbol)

    add_reserved: (name) ->
      @__proto__.accessor "_#{name.toUpperCase()}_", -> @_IDENTIFIER(name)
      @_reserved.push name.toLowerCase()

    advance: ->
      @_scanned.push @token
      if !@isEOF()
        @_current++
        return true
      else
        return false

    peek_prev: -> if @_current - 1 >= 0 then @_tokens[@_current - 1] else null

    peek_next: -> if @_current + 1 < @_tokens.length then @_tokens[@_current + 1] else null

    isEOF: -> @_current == @_tokens.length - 1

    isBOF: -> @_current == 0

    accept: (test, type = 'UNKNOWN') ->
      if test?
        r = test.call @
      else
        r = false
      if r and @_scanned.length > 0
        @_lexemes.push type: type, tokens: _.clone(@_scanned)
      @_scanned = []
      return r

    match: (text, against, casesensitive = false) ->
      if _.isString(against)
        if !casesensitive
          return text.toLowerCase() == against.toLowerCase()
        else
          return text == against

      else if _.isRegExp(against)
        return against.test(text)

      else if _.isFunction(against)
        return against(text)

      else if _.isArray(against)
        for a in against
          if @match(text, a, casesensitive)
            return true

      return false

    error: (msg) -> throw new Error("#{msg} at #{@_tokenizer.tokenInfo(@_tokens[i])}")

    _IDENTIFIER: (value) ->
      return false if !@token.type == @_tokenizer.types.IDENTIFIER
      if !value? or @match(@token.value, value)
        return @advance()
      else
        return false

    _SYMBOL: (value) ->
      return false if !@token.type == @_tokenizer.types.SYMBOL
      if !value? or @match(@token.value, value)
        return @advance()
      else
        return false

    _CONST: (value) ->
      if @token.type == @_tokenizer.types.CONSTANT
        return @advance()
      else
        return false

    _STRING: (value) ->
      if @token.type == @_tokenizer.types.STRING
        return @advance()
      else
        return false

    _TYPE: (value) -> @match(@token.type, value)

    parse: (text, path) ->
      @_lexemes = []
      @_current = 0
      @_scanned = []

      if _.isString(text)
        @_tokenizer = new Swim.Tokenizer()
        @_tokens = @_tokenizer.scan(text, path)
      else if text instanceof Swim.Tokenizer
        @_tokenizer = text
        @_tokens = @_tokenizer.tokens

      while !@isEOF()
        @_scanned = []
        if !@main()
          @_current++ if !@isEOF()

      return @_lexemes

    main: -> false
