t = Swim.terminals[0]

t.font = Swim.getFont(name: "FontAwesome", size: 18, smooth: true)
t.blue.write("\uf1b2").reset.write("\uf238\uf1ec").cr.cr

t.font = Swim.getFont(name: "Lucida Console", size: 20, smooth: true)
t.write("Testing this font out. \u2a05\u22a2\u22a3\u228f\u2290\u2b1c \u2b1c \u2517\u2501\u2501\u2501\u251B \u25C4\u2501").cr.cr
