{ Tokenizer, Lexer } = Swim

Swim.lexers.C_Lexer = class C_Lexer extends Lexer

  constructor: ->
    super

    for i in 'auto,break,case,char,const,continue,default,do,double,else,enum,extern,float,for,goto,if,int,long,register,return,short,signed,sizeof,static,struct,switch,typedef,union,unsigned,void,volatile,while'.split(',')
      @add_reserved i

  main: ->
    @translation_unit()

  primary_expression: ->
    @accept ->
      @_IDENTIFIER() or
      @_CONST() or
      @_STRING() or
      (@_LPAREN_ and @expression() and @_RPAREN_)
    , "PRIMARY_EXPRESSION"

  postfix_expression: ->
    @accept ->
      @primary_expression() or
      (@_LBRACK_ and @expression() and @_RBRACK_) or
      (@_LPAREN_ and @_RPAREN_) or
      (@_LPAREN_ and @argument_expression_list() and @_RPAREN_) or
      (@_DOT_ and @_IDENTIFIER()) or
      (@_PTR_OP_ and @_IDENTIFIER()) or
      @_INC_OP_ or
      @_DEC_OP_
    , "POSTFIX_EXPRESSION"

  argument_expression_list: ->
    @accept ->
      @assignment_expression() or
      (@argument_expression_list() and @_COMMA_ and @assignment_expression())
    , "ARGUMENT_EXPRESSION_LIST"

  unary_expression: ->
    @accept ->
      @postfix_expression() or
      (@_INC_OP_ and @unary_expression()) or
      (@_DEC_OP_ and @unary_expression()) or
      (@unary_operator and @cast_expression()) or
      (@_SIZEOF_ and @unary_expression()) or
      (@_SIZEOF_ and @_LPAREN_ and @type_name() and @_RPAREN_)
    , "UNARY_EXPRESSION"

  unary_operator: ->
    @accept ->
      @_BIT_AND_ or
      @_MUL_OP_ or
      @_ADD_OP_ or
      @_SUB_OP_ or
      @_TILDE_ or
      @_NEG_OP_
    , "UNARY_OPERATOR"

  cast_expression: ->
    @accept ->
      @unary_expression() or
      (@_LPAREN_ and @type_name() and @_RPAREN_ and @cast_expression())
    , "CAST_EXPRESSION"

  multiplicative_expression: ->
    @accept ->
      @cast_expression() or
      (@multiplicative_expression() and @_MUL_OP_ and @cast_expression()) or
      (@multiplicative_expression() and @_DIV_OP_ and @cast_expression()) or
      (@multiplicative_expression() and @_MOD_OP_ and @cast_expression())
    , "MULTIPLICATIVE_EXPRESSION"

  additive_expression: ->
    @accept ->
      @multiplicative_expression() or
      (@additive_expression() and @_ADD_OP_ and @multiplicative_expression()) or
      (@additive_expression() and @_SUB_OP_ and @multiplicative_expression())
    , "ADDITIVE_EXPRESSION"

  shift_expression: ->
    @accept ->
      @additive_expression() or
      (@shift_expression() and @_LEFT_OP_ and @additive_expression()) or
      (@shift_expression() and @_RIGHT_OP_ and @additive_expression())
    , "SHIFT_EXPRESSION"

  relational_expression: ->
    @accept ->
      @shift_expression() or
      (@relational_expression() and @_LT_OP_ and @shift_expression()) or
      (@relational_expression() and @_GT_OP_ and @shift_expression()) or
      (@relational_expression() and @_LE_OP_ and @shift_expression()) or
      (@relational_expression() and @_GE_OP_ and @shift_expression())
    , "RELATIONAL_EXPRESSION"

  equality_expression: ->
    @accept ->
      @relational_expression() or
      (@equality_expression() and @_EQ_OP_ and @relational_expression()) or
      (@equality_expression() and @_NE_OP_ and @relational_expression())
    , "EQUALITY_EXPRESSION"

  and_expression: ->
    @accept ->
      @equality_expression() or
      (@and_expression() and @_BIT_AND_ and @equality_expression())
    , "AND_EXPRESSION"

  exclusive_or_expression: ->
    @accept ->
      @and_expression() or
      (@exclusive_or_expression() and @_BIT_XOR_ and @and_expression())
    , "EXCLUSIVE_OR_EXPRESSION"

  inclusive_or_expression: ->
    @accept ->
      @exclusive_or_expression() or
      (@inclusive_or_expression() and @_BIT_OR_ and @exclusive_or_expression())
    , "INCLUSIVE_OR_EXPRESSION"

  logical_and_expression: ->
    @accept ->
      @inclusive_or_expression() or
      (@logical_and_expression() and @_AND_OP_ and @inclusive_or_expression())
    , "LOGICAL_AND_EXPRESSION"

  logical_or_expression: ->
    @accept ->
      @logical_and_expression() or
      (@logical_or_expression() @_OR_OP_ and @logical_and_expression())
    , "LOGICAL_OR_EXPRESSION"

  conditional_expression: ->
    @accept ->
      @logical_or_expression() or
      (@logical_or_expression() and @_QMARK_ and @expression() and @_COLON_ and @conditional_expression())
    , "CONDITIONAL_EXPRESSION"

  assignment_expression:->
    @accept ->
      @conditional_expression() or
      (@unary_expression() and @assignment_operator() and @assignment_expression())
    , "ASSIGNMENT_EXPRESSION"

  assignment_operator: ->
    @accept ->
      @_ASSIGN_ or
      @_MUL_ASSIGN_ or
      @_DIV_ASSIGN_ or
      @_MOD_ASSIGN_ or
      @_ADD_ASSIGN_ or
      @_SUB_ASSIGN_ or
      @_LEFT_ASSIGN_ or
      @_RIGHT_ASSIGN_ or
      @_AND_ASSIGN_ or
      @_XOR_ASSIGN_ or
      @_OR_ASSIGN_
    , "ASSIGNMENT_OPERATOR"

  expression: ->
    @accept ->
      @assignment_expression() or
      (@expression() and @_COMMA_ and @assignment_expression())
    , "EXPRESSION"

  constant_expression: ->
    @accept ->
      @conditional_expression()
    , "CONSTANT"

  declaration: ->
    @accept ->
      (@declaration_specifiers() and @_SEMICOLON_) or
      (@declaration_specifiers() and @init_declarator_list() and @_SEMICOLON_)
    , "DECLARATION"

  declaration_specifiers: ->
    @accept ->
      @storage_class_specifier() or
      (@storage_class_specifier() and @declaration_specifiers()) or
      @type_specifier() or
      (@type_specifier() and @declaration_specifiers()) or
      @type_qualifier() or
      (@type_qualifier() and @declaration_specifiers())
    , "DECLARATION_SPECIFIERS"

  init_declarator_list: ->
    @accept ->
      @init_declarator() or
      (@init_declarator_list() and @_COMMA_ and @init_declarator())
    , "INIT_DECLARATOR_LIST"

  init_declarator: ->
    @accept ->
      @declarator() or
      (@declarator() and @_ASSIGN_ and @initializer())
    , "INIT_DECLARATOR"

  storage_class_specifier: ->
    @accept ->
      @_TYPEDEF_ or
      @_EXTERN_ or
      @_STATIC_ or
      @_AUTO_ or
      @_REGISTER_
    , "STORAGE_CLASS_SPECIFIER"

  type_specifier: ->
    @accept ->
      @_VOID_ or
      @_CHAR_ or
      @_SHORT_ or
      @_INT_ or
      @_LONG_ or
      @_FLOAT_ or
      @_DOUBLE_ or
      @_SIGNED_ or
      @_UNSIGNED_ or
      @struct_or_union_specifier() or
      @enum_specifier() or
      @type_name()
    , "TYPE_SPECIFIER"

  struct_or_union_specifier: ->
    @accept ->
      (@struct_or_union() and @_IDENTIFIER() and @_LBRACE_ and @struct_declaration_list() and @_RBRACE_) or
      (@struct_or_union() and @_LBRACE_ and @struct_declaration_list() and @_RBRACE_) or
      (@struct_or_union() and @_IDENTIFIER())
    , "STRUCT_OR_UNION_SPECIFIER"

  struct_or_union: ->
    @accept ->
      @_STRUCT_ or
      @_UNION_
    , "STRUCT_OR_UNION"

  struct_declaration_list: ->
    @accept ->
      @struct_declaration() or
      (@struct_declaration_list() and @struct_declaration())
    , "STRUCT_DECLARATION_LIST"

  struct_declaration: ->
    @accept ->
      @specifier_qualifier_list() and @struct_declarator_list() and @_SEMICOLON_
    , "STRUCT_DECLARATION"

  specifier_qualifier_list: ->
    @accept ->
      (@type_specifier() and @specifier_qualifier_list()) or
      @type_specifier() or
      (@type_qualifier() and @specifier_qualifier_list()) or
      @type_qualifier()
    , "SPECIFIER_QUALIFIER_LIST"

  struct_declarator_list: ->
    @accept ->
      @struct_declarator() or
      (@struct_declarator_list() and @_COMMA_ and @struct_declarator())
    , "STRUCT_DECLARATOR_LIST"

  struct_declarator: ->
    @accept ->
      @declarator() or
      (@_COLON_ and @constant_expression()) or
      (@declarator() and @_COLON_ and @constant_expression())
    , "STRUCT_DECLARATOR"

  enum_specifier: ->
    @accept ->
      (@_ENUM_ and @_LBRACE_ and @enumerator_list() and @_RBRACE_) or
      (@_ENUM_ and @_IDENTIFIER() and @_LBRACE_ and @enumerator_list() and @_RBRACE_) or
      (@_ENUM_ and @_IDENTIFIER())
    , "ENUM_SPECIFIER"

  enumerator_list: ->
    @accept ->
      @enumerator() or
      (@enumerator_list() and @_COMMA_ and @enumerator())
    , "ENUMERATOR_LIST"

  enumerator: ->
    @accept ->
      @_IDENTIFIER() or
      (@_IDENTIFIER() and @_ASSIGN_ and @constant_expression())
    , "ENUMERATOR"

  type_qualifier: ->
    @accept ->
      @_CONST() or
      @_VOLATILE_
    , "TYPE_QUALIFIER"

  declarator: ->
    @accept ->
      (@_POINTER_ and @direct_declarator()) or
      @direct_declarator()
    , "DECLARATOR"

  direct_declarator: ->
    @accept ->
      @_IDENTIFIER() or
      (@_LPAREN_ and @declarator() and @_RPAREN_) or
      (@direct_declarator() and @_LBRACK_ and @constant_expression() and @_RBRACK_) or
      (@direct_declarator() and @_LBRACK_ and @_RBRACK_) or
      (@direct_declarator() and @_LPAREN_ and @parameter_type_list() and @_RPAREN_) or
      (@direct_declarator() and @_LPAREN_ and @identifier_list()) or
      (@direct_declarator() and @_LPAREN_ and @_RPAREN_)
    , "DIRECT_DECLARATOR"

  pointer: ->
    @accept ->
      @_MUL_OP_ or
      (@_MUL_OP_ and @type_qualifier_list()) or
      (@_MUL_OP_ and @_POINTER_) or
      (@_MUL_OP_ and @type_qualifier_list() and @_POINTER_)
    , "POINTER"

  type_qualifier_list: ->
    @accept ->
      @type_qualifier() or
      (@type_qualifier_list() and @type_qualifier())
    , "TYPE_QUALIFIER_LIST"

  parameter_type_list: ->
    @accept ->
      @parameter_list() or
      (@parameter_list() and @_COMMA_ and @ellipsis())
    , "PARAMETER_TYPE_LIST"

  parameter_list: ->
    @accept ->
      @parameter_declaration() or
      (@parameter_list() and @_COMMA_ and @parameter_declaration())
    , "PARAMETER_LIST"

  parameter_declaration: ->
    @accept ->
      (@declaration_specifiers() and @declarator()) or
      (@declaration_specifiers() and @abstract_declarator()) or
      @declaration_specifiers()
    , "PARAMETER_DECLARATION"

  identifier_list: ->
    @accept ->
      @_IDENTIFIER() or
      (@identifier_list() and @_COMMA_ and @_IDENTIFIER())
    , "IDENTIFIER_LIST"

  type_name: ->
    @accept ->
      @specifier_qualifier_list() or
      (@specifier_qualifier_list() and @abstract_declarator())
    , "TYPE_NAME"

  abstract_declarator: ->
    @accept ->
      @_POINTER_ or
      @direct_abstract_declarator() or
      (@_POINTER_ and @direct_abstract_declarator())
    , "ABSTRACT_DECLARATOR"

  direct_abstract_declarator: ->
    @accept ->
      (@_LPAREN_ and @abstract_declarator() and @_RPAREN_) or
      (@_LBRACK_ and @_RBRACK_) or
      (@_LBRACK_ and @constant_expression() and @_RBRACK_) or
      (@direct_abstract_declarator() and @_LBRACK_ and @_RBRACK_) or
      (@direct_abstract_declarator() and @_LBRACK_ and @constant_expression() and @_RBRACK_) or
      (@_LPAREN_ and @_RPAREN_) or
      (@_LPAREN_ and @parameter_type_list() and @_RPAREN_) or
      (@direct_abstract_declarator() and @_LPAREN_ and @_RPAREN_) or
      (@direct_abstract_declarator() and @_LPAREN_ and @parameter_type_list() and @_RPAREN_)
    , "DIRECT_ABSTRACT_DECLARATOR"

  initializer: ->
    @accept ->
      @assignment_expression() or
      (@_LBRACE_ and @initializer_list() and @_RBRACE_) or
      (@_LBRACE_ and @initializer_list() and @_COMMA_ and @_RBRACE_)
    , "INITIALIZER"

  initializer_list: ->
    @accept ->
      @initializer() or
      (@initializer_list() and @_COMMA_ and @initializer())
    , "INITIALIZER_LIST"

  statement: ->
    @accept ->
      @labeled_statement() or
      @compound_statement() or
      @expression_statement() or
      @selection_statement() or
      @iteration_statement() or
      @jump_statement()
    , "STATEMENT"

  labeled_statement: ->
    @accept ->
      (@_IDENTIFIER() and @_COLON_ and @statement()) or
      (@_CASE_ and @constant_expression() and @_COLON_ and @statement()) or
      (@_DEFAULT_ and @_COLON_ and @statement())
    , "LABELED_STATEMENT"

  compound_statement: ->
    @accept ->
      (@_LBRACE_ and @_RBRACE_) or
      (@_LBRACE_ and @statement_list() and @_RBRACE_) or
      (@_LBRACE_ and @declaration_list() and @_RBRACE_) or
      (@_LBRACE_ and @declaration_list() and @statement_list() and @_RBRACE_)
    , "COMPOUND_STATEMENT"

  declaration_list: ->
    @accept ->
      @declaration() or
      (@declaration_list() and @declaration())
    , "DECLARATION_LIST"

  statement_list: ->
    @accept ->
      @statement() or
      (@statement_list() and @statement())
    , "STATEMENT_LIST"

  expression_statement: ->
    @accept ->
      @_SEMICOLON_ or
      (@expression() and @_SEMICOLON_)
    , "EXPRESSION_STATEMENT"

  selection_statement: ->
    @accept ->
      (@IF and @_LPAREN_ and @expression() and @_RPAREN_ and @statement()) or
      (@IF and @_LPAREN_ and @expression() and @_RPAREN_ and @statement() and @ELSE and @statement()) or
      (@SWITCH and @_LPAREN_ and @expression() and @_RPAREN_ and @statement())
    , "SELECTION_STATEMENT"

  iteration_statement: ->
    @accept ->
      (@_WHILE_ and @_LPAREN_ and @expression() and @_RPAREN_ and @statement()) or
      (@_DO_ and @statement() and @_WHILE_ and @_LPAREN_ and @expression() and @_RPAREN_ and @_SEMICOLON_) or
      (@_FOR_ and @_LPAREN_ and @expression_statement() and @expression_statement() and @_RPAREN_ and @statement()) or
      (@_FOR_ and @_LPAREN_ and @expression_statement() and @expression_statement() and @expression() and @_RPAREN_ and @statement())
    , "ITERATION_STATEMENT"

  jump_statement: ->
    @accept ->
      (@_GOTO_ and @_IDENTIFIER() and @_SEMICOLON_) or
      (@_CONTINUE_ and @_SEMICOLON_) or
      (@_BREAK_ and @_SEMICOLON_) or
      (@_RETURN_ and @_SEMICOLON_) or
      (@_RETURN_ and @expression() and @_SEMICOLON_)
    , "JUMP_STATEMENT"

  translation_unit: ->
    @accept ->
      @external_declaration() or
      (@translation_unit() and @external_declaration())
    , "TRANSLATION_UNIT"

  external_declaration: ->
    @accept ->
      @function_definition() or
      @declaration()
    , "EXTERNAL_DECLARATION"

  function_definition: ->
    @accept ->
      (@declaration_specifiers() and @declarator() and @declaration_list() and @compound_statement()) or
      (@declaration_specifiers() and @declarator() and @compound_statement()) or
      (@declarator() and @declaration_list() and @compound_statement()) or
      (@declarator() and @compound_statement())
    , "FUNCTION_DEFINITION"
