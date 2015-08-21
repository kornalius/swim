t = Swim.terminals[0]

f = Swim.getFont(name: "Glass TTY VT220", size: 20)

t2 = new Swim.Terminal(pos: new PIXI.Point(2, 42), size: new PIXI.Point(50, 2), palette: Swim.palettes.default, charWidth: 11, charHeight: 20, padding: 0, border: { width: 1, fg: 0x888888 }, cursor: { type: 'underline' })
t2.font = f
t2.z = 1
t.addTerminal(t2)
t2.write("Embedded Terminal").cr.write("Woohoo! This is AWESOME!")

t3 = new Swim.Terminal(pos: new PIXI.Point(38, 41), size: new PIXI.Point(50, 2), palette: Swim.palettes.default, charWidth: 11, charHeight: 20, padding: 2, border: { width: 2, fg: 0x888888 }, cursor: { type: 'block' })
t3.font = f
t.addTerminal(t3)
t3.write("Bottom Embedded Terminal").cr.write("Now this is cool!")
