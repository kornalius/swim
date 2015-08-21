t = Swim.terminals[0]

t.red.write("red text").yellow.write(" some yellow").reset

t.write "  \x1b[s\x1b[2A\x1b[31;3mitalic and red\x1b[0;33myellow\x1b[0m\x1b[u"

cc = 19
for c in "256 colors support!"
  t.write "\x1b[48;5;#{Math.trunc(cc)}m#{c}\x1b[0m"
  cc += 1.5

t.write("\x1b[0m").cr.cr
