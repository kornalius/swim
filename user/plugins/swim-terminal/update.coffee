Swim.updates =
  render: false
  fonts: []
  chars: []
  cursors: []
  terminals: []

  addFont: (f) ->
    if !f.__addedToUpdates
      Swim.updates.fonts.push f
      f.__addedToUpdates = true

  addChar: (c) ->
    if !c.__addedToUpdates
      Swim.updates.chars.push c
      c.__addedToUpdates = true

  addCursor: (c) ->
    if !c.__addedToUpdates
      Swim.updates.cursors.push c
      c.__addedToUpdates = true

  delCursor: (c) ->
    @addCursor(c)
    c.__destroy = true

  addTerminal: (t) ->
    if !t.__addedToUpdates
      Swim.updates.terminals.push t
      t.__addedToUpdates = true


_lastMouse = new PIXI.Point()

# tick = Date.now()
PIXI.ticker.shared.add (time) ->
  # if Date.now() - tick > 10
    # for t in Swim.terminals
      # for c in t.chars()
        # c.fg = Math.random() * 0xFFFFFF
    # tick = Date.now()


  if Swim.updates.fonts.length
    for f in Swim.updates.fonts
      for l in f._cached
        l._text.texture._updateUvs()
    for t in Swim.terminals
      t._update()
      t.__addedToUpdates = false

    # console.log "update fonts #{Swim.updates.fonts.length}..."
    Swim.updates.fonts = []
    Swim.updates.render = true


  if Swim.updates.chars.length
    for c in Swim.updates.chars
      c.__addedToUpdates = false
      t = c._terminal
      if t?
        update = false
        pp = null
        if c._ch == ' '
          if c._letter?
            t._textLayer.removeChild(c._letter)
            c._letter = null
            update = true
        else
          f = c._font.frame(c._ch)
          if f?
            pp = t.posToPixel(c._pos, true)
            if !c._letter?
              c._letter = new PIXI.Sprite()
              # c._letter.name = "TerminalChar #{c._ch}"
              c._letter.position.x = pp.x + 1
              c._letter.position.y = pp.y - 1
              t._textLayer.addChild(c._letter)
              update = true
            if (!c.__oldFrame or c.__oldFrame.x != f.frame.x or c.__oldFrame.y != f.frame.y or c.__oldFrame.width != f.frame.width or c.__oldFrame.height != f.frame.height or c.__oldTexture != f.line.texture)
              c._letter.texture = new PIXI.Texture(f.line.texture.baseTexture, f.frame)
              update = true
            if c._letter.tint != c._fg
              c._letter.tint = c._fg
              update = true
            if f.frame.width != t._charWidth and !c._wide
              c._letter.position.x = Math.ceil(pp.x + 1 + (t._charWidth - f.frame.width) * 0.5)
              update = true
            if c._wide
              c._letter.position.y = Math.ceil(pp.y + (t._charHeight - f.frame.height) * 0.5)
              update = true

        if !c._parent?
          if c._bg == t._palette.bg
            if c._back?
              c._back.parent.removeChild(c._back)
              c._back = null
              update = true
          else
            if !c._back?
              if !pp?
                pp = t.posToPixel(c._pos, true)
              c._back = new PIXI.Sprite(t._backSprite.texture)
              c._back.position.x = pp.x
              c._back.position.y = pp.y
              t._backTextLayer.addChild(c._back)
              update = true
            if c._back.tint != c._bg
              c._back.tint = c._bg
              update = true

        if update
          t._update()

    # console.log "update chars #{done} / #{Swim.updates.chars.length}..."

    Swim.updates.chars = []
    Swim.updates.render = true


  if Swim.updates.cursors.length
    for c in Swim.updates.cursors
      c.__addedToUpdates = false

      t = c._terminal

      if c.__destroy
        c.emit 'destroy'
        if t?
          _.remove(t.cursors, c)
        if c._sprite?
          c._sprite.parent.removeChild(c._sprite)
          c._sprite.destroy()
          c._sprite = null
        c._terminal = null

      else if t?

        if c._sprite? and (c.width != c._sprite.width or c.height != c._sprite.height)
          c._sprite.parent.removeChild(c._sprite)
          c._sprite.destroy()
          c._sprite = null

        if !c._sprite?
          g = new PIXI.Graphics()
          g.clear()
          g.beginFill(c._bg)
          g.drawRect(0, 0, c.width, c.height)
          g.endFill()
          tex = g.generateTexture(Swim.renderer, 1, 0)
          c._sprite = new PIXI.Sprite(tex)
          c._sprite.cacheAsBitmap = true
          t.addChild(c._sprite)

        pp = t.posToPixel(c._pos, true)

        if c._sprite.position.x != pp.x or c._sprite.position.y != pp.y
          c.emit 'move', pp
          t.emit 'cursor:move', c, pp

        c._sprite.position.x = pp.x + c._offset.x
        c._sprite.position.y = pp.y + c._offset.y
        c._sprite.visible = c._visible and c._state.visible and c._inBounds(c._pos)

    # console.log "update cursors #{Swim.updates.cursors.length}..."
    Swim.updates.cursors = []
    Swim.updates.render = true


  if Swim.updates.terminals.length
    for t in Swim.updates.terminals
      t.__addedToUpdates = false
      t._updateBackSprite()
      t._updateBackLayer()
      t._updateBackTextLayer()
      t._updateTextLayer()
      t._updateBorderLayer()
      t._updateFocusLayer()
      if t._focused
        t.showCursors()
      else
        t.hideCursors()
      t.emit 'terminal:change'

    # console.log "update terminals #{Swim.updates.terminals.length}..."
    Swim.updates.terminals = []
    Swim.updates.render = true


  if Swim.updates.render
    Swim.renderer.render(Swim.stage)
    Swim.updates.render = false
