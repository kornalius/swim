t = Swim.terminals[0]

items = []
for i in [0..100]
  items.push "Item #{i}"

tt = new Swim.ListView(items: items, pos: new PIXI.Point(50, 2), size: new PIXI.Point(20, 10), palette: Swim.palettes.default, charWidth: 11, charHeight: 20, padding: 2, border: { width: 1, fg: 0x888888 }, font: { name: "Glass TTY VT220", size: 20, smooth: true })

t.addTerminal(tt)
tt.scrollInView()
tt.setFocus()
