
linetokens = Swim.lexer.lexSync fileContents: "var hello = 'world';", scopeName: 'source.js'

console.log JSON.stringify linetokens, null, 2
