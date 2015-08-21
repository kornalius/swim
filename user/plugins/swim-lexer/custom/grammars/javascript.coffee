{ Tokenizer, Lexer } = Swim

Swim.lexers.JS_Lexer = class JS_Lexer extends Lexer

  constructor: ->
    super
    for i in 'var,function,class'.split(',')
      @add_reserved i

  main: ->
    @accept ->
      @var_definition() or
      @function_definition() or
      @class_definition()
    , "MAIN"

  var_definition: ->
    @accept ->
      @_VAR_ and @_IDENTIFIER()
    , "VAR"

  function_definition: ->
    @accept ->
      @_FUNCTION_ and @_IDENTIFIER()
    , "FUNCTION"

  class_definition: ->
    @accept ->
      @_CLASS_ and @_IDENTIFIER()
    , "CLASS"

