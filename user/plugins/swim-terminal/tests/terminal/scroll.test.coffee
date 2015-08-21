t = Swim.terminals[0]

pp = new PIXI.Point(0, 1)
setInterval ->
  t.scrollBy(pp)
