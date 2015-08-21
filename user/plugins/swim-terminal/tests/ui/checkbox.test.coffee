t = Swim.terminals[0]

tt = new Swim.Checkbox(pos: new PIXI.Point(50, 5), palette: Swim.palettes.default, charWidth: 11, charHeight: 20, padding: 2, border: { width: 1, fg: 0x888888 }, font: { name: "Glass TTY VT220", size: 20, smooth: true }, label: "Click me buddy!", checked: true)

t.addTerminal(tt)
tt.scrollInView()
tt.setFocus()
