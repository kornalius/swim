{ Plugin } = Swim

Number.prototype.round = (places, increment) ->
  increment = increment || 1e-20
  factor = 10 / (10 * (increment || 10))
  (Math.ceil(factor * +@valueOf()) / factor).toFixed(places) * 1

Number.prototype.roundCeil = (places) ->
  powed = Math.pow(10, places)
  Math.ceil(@valueOf() * powed) / powed

Number.prototype.sign = ->
  if @valueOf() > 0
    1
  else if @valueOf() < 0
    -1
  else
    0

Number.prototype.wrap = (min, max) ->
  value = @valueOf()

  if min > max
    [min, max] = [max, min]

  if value < min
    min
  else if value > max
    max
  else
    value

Number.prototype.loop = (min, max) ->
  value = @valueOf()

  if min is max
    min
  else
    if min > max
      [min, max] = [max, min]

    vol = max - min
    val = value - max

    while val < 0
      val += vol
    (val % vol) + min

Number.prototype.add = (nums...) ->
  n = @valueOf()
  n += num for num in nums
  n

Number.prototype.sub = (nums...) ->
  base = @valueOf()
  if nums.length
    base -= num for num in nums
    base
  else
    -base

Number.prototype.mul = (nums...) ->
  n = @valueOf()
  n *= num for num in nums
  n

Number.prototype.div = (nums...) ->
  base = @valueOf()
  if nums.length
    base /= num for num in nums
    base
  else
    1 / base

Number.prototype.radToDeg = ->
  @valueOf() * 57.29577951308232

Number.prototype.degToRad = ->
  valueOf() * 0.017453292519943295

Number.prototype.format = (mask) ->
  value = @valueOf()
  if !mask or isNaN(+value)
    return value
    # return as it is.
  isNegative = undefined
  result = undefined
  decimal = undefined
  group = undefined
  posLeadZero = undefined
  posTrailZero = undefined
  posSeparator = undefined
  part = undefined
  szSep = undefined
  integer = undefined
  len = mask.length
  start = mask.search(/[0-9\-\+#]/)
  prefix = if start > 0 then mask.substring(0, start) else ''
  str = mask.split('').reverse().join('')
  end = str.search(/[0-9\-\+#]/)
  offset = len - end
  indx = offset + (if mask.substring(offset, offset + 1) == '.' then 1 else 0)
  suffix = if end > 0 then mask.substring(indx, len) else ''
  # mask with prefix & suffix removed
  mask = mask.substring(start, indx)
  # convert any string to number according to formation sign.
  value = if mask.charAt(0) == '-' then -value else +value
  isNegative = if value < 0 then (value = -value) else 0
  # process only abs(), and turn on flag.
  # search for separator for grp & decimal, anything not digit, not +/- sign, not #.
  result = mask.match(/[^\d\-\+#]/g)
  decimal = result and result[result.length - 1] or '.'
  # treat the right most symbol as decimal
  group = result and result[1] and result[0] or ','
  # treat the left most symbol as group separator
  # split the decimal for the format string if any.
  mask = mask.split(decimal)
  # Fix the decimal first, toFixed will auto fill trailing zero.
  value = value.toFixed(mask[1] and mask[1].length)
  value = +value + ''
  # convert number to string to trim off *all* trailing decimal zero(es)
  # fill back any trailing zero according to format
  posTrailZero = mask[1] and mask[1].lastIndexOf('0')
  # look for last zero in format
  part = value.split('.')
  # integer will get !part[1]
  if !part[1] or part[1] and part[1].length <= posTrailZero
    value = (+value).toFixed(posTrailZero + 1)
  szSep = mask[0].split(group)
  # look for separator
  mask[0] = szSep.join('')
  # join back without separator for counting the pos of any leading 0.
  posLeadZero = mask[0] and mask[0].indexOf('0')
  if posLeadZero > -1
    while part[0].length < mask[0].length - posLeadZero
      part[0] = '0' + part[0]
  else if +part[0] == 0
    part[0] = ''
  value = value.split('.')
  value[0] = part[0]
  # process the first group separator from decimal (.) only, the rest ignore.
  # get the length of the last slice of split result.
  posSeparator = szSep[1] and szSep[szSep.length - 1].length
  if posSeparator
    integer = value[0]
    str = ''
    offset = integer.length % posSeparator
    len = integer.length
    indx = 0
    while indx < len
      str += integer.charAt(indx)
      # ie6 only support charAt for sz.
      # -posSeparator so that won't trail separator on full length

      ###jshint -W018 ###

      if !((indx - offset + 1) % posSeparator) and indx < len - posSeparator
        str += group
      indx++
    value[0] = str
  value[1] = if mask[1] and value[1] then decimal + value[1] else ''
  # remove negative sign if result is zero
  result = value.join('')
  if result == '0' or result == ''
    # remove negative sign if result is zero
    isNegative = false
  # put back any negation, combine integer and fraction, and add back prefix & suffix
  prefix + (if isNegative then '-' else '') + result + suffix

Math.clockwise = (from, to, range) ->
  while to > from
    to -= range
  while to < from
    to += range
  return to - from

Math.nearer = (from, to, range) ->
  c = clockwise(from, to, range)
  if c >= range * 0.5 then c - range else c

Math.average = (nums...) ->
  add(nums...) / nums.length

Math.between = (to, ratio) ->
  from = @valueOf()
  from + (to - from) * ratio

oldMathRandom = Math.random
Math.random = (nums...) ->
  if nums.length is 0
    oldMathRandom()
  else if nums.length is 1
    oldMathRandom() * nums[0]
  else
    oldMathRandom() * (nums[1] - nums[0]) + nums[0]

Math.bitwiseAnd = _.number.bitwiseAnd
Math.bitwiseOr = _.number.bitwiseOr
Math.bitwiseXor = _.number.bitwiseXor
Math.bitwiseLeft = _.number.bitwiseLeft
Math.bitwiseRight = _.number.bitwiseRight
Math.bitwiseZ = _.number.bitwiseZ
Math.bitwiseNot = _.number.bitwiseNot
