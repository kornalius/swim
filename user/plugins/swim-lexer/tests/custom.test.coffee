require('../custom/tokenizer.coffee')
require('../custom/lexer.coffee')

Swim.lexers = {}

# require('../custom/grammars/c.coffee')
require('../custom/grammars/javascript.coffee')

src = """
  var i = 0;
  i = i + 20;
  if (i >= 20) {
    console.log('string');
  }
  function fn () {
    console.log('fn called');
  }
  fn();
"""

t = new Swim.Tokenizer()
tokens = t.scan(src, "")
# for tk in tokens
  # console.log t.tokenInfo(tk)

l = new Swim.lexers.JS_Lexer()
lexemes = l.parse(t, "")
for lm in lexemes
  console.log "** #{lm.type} **"
  for tk in lm.tokens
    console.log "    #{t.tokenInfo(tk)}"

Swim.Tokenizer = null
Swim.Lexer = null
