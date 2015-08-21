{ Plugin } = Swim

Boolean.prototype.not = -> !@valueOf()

Boolean.prototype.or = (bools...) ->
  r = @valueOf()
  for a in bools
    r = r or _.toBoolean(a)
  b r

Boolean.prototype.xor = (bools...) ->
  r = @valueOf()
  for a in bools
    r = r ^ _.toBoolean(a)
  b r


Boolean.prototype.and = (bools...) ->
  r = @valueOf()
  for a in bools
    r = r and _.toBoolean(a)
  b r

