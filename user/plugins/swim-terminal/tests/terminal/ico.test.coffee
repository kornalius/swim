t = Swim.terminals[0]

s = Swim.ico
for i in [0xf000..0xf32e]
  s += String.fromCharCode(i)
s += Swim.icof

t.write(s)

t.cr.cr
