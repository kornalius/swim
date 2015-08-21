t = Swim.terminals[0]

tt = new Swim.TextView( text: "Some default text", pos: new PIXI.Point(40, 3), size: new PIXI.Point(30, 1), palette: Swim.palettes.default, charWidth: 11, charHeight: 20, padding: 2, border: { width: 1, fg: 0x888888 }, font: { name: "Glass TTY VT220", size: 20, smooth: true }, cursor: { type: 'caret', wrap: false })

tt.textCursor.moveToLineEnd()
tt.textCursor.insert(", enhanced with power!")

t.addTerminal(tt)
tt.scrollInView()
tt.setFocus()
