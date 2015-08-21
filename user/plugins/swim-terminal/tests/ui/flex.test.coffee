{ Point } = Swim.PIXI

t = Swim.terminals[0]

v = new Swim.View
  pos: new Point(2, 44)
  charWidth: 11
  charHeight: 20
  size: new Point(60, 3)
  z: 3
  border:
    width: 1
    fg: 0x888888
  flex:
    layout: 'horizontal'
    align: 'center-center'
    # justify: 'around'
    max: new Point(60, 10)
t.addTerminal(v)

cv1 = new Swim.View
  charWidth: 11
  charHeight: 20
  bg: 0x00FF00
  border:
    width: 1
    fg: 0x888888
  flex:
    size: 'two'
v.addTerminal(cv1)

cv2 = new Swim.View
  charWidth: 11
  charHeight: 20
  bg: 0x0000FF
  border:
    width: 1
    fg: 0x888888
  flex:
    size: 'none'
v.addTerminal(cv2)

cv3 = new Swim.View
  charWidth: 11
  charHeight: 20
  bg: 0x00FFFF
  border:
    width: 1
    fg: 0x888888
  flex:
    size: 'flex'
v.addTerminal(cv3)
