
t = new Swim.Terminal(pos: new PIXI.Point(2, 2), size: new PIXI.Point(160, 45), palette: Swim.palettes.default, charWidth: 11, charHeight: 20, padding: 4, border: { width: 2, fg: 0x333333 })
Swim.stage.addChild t

t.font = Swim.getFont(name: "Glass TTY VT220", size: 20)

for i in [0...10]
  t.write("This is a first experiment ]\u25CC[ ]\u25CA[").cr

t.cursor.cr()

for i in [0...50]
  t.write("0123456789")

t.cr.cr


require('./ansi.test.coffee')
require('./layers.test.coffee')
require('./ico.test.coffee')
require('./fonts.test.coffee')
require('./html.test.coffee')
require('./children.test.coffee')
# require('./scroll.test.coffee')
# require('./bell.test.coffee')
