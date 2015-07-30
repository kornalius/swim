fs = require('fs');

RGBFilter = ->
  PIXI.AbstractFilter.call @,
    # vertex shader
    null,
    # fragment shader
    fs.readFileSync(__dirname + '/rgb.frag', 'utf8'),
    # custom uniforms
    dimensions:
      type: '4fv'
      value: new Float32Array([0, 0, 0, 0])
    time:
      type: '1f'
      value: 0

RGBFilter.prototype = Object.create(PIXI.AbstractFilter.prototype)
RGBFilter.prototype.constructor = RGBFilter
module.exports = RGBFilter

Object.defineProperties RGBFilter.prototype,
  dimensions:
    get: -> @uniforms.dimensions.value
    set: (value) -> @uniforms.dimensions.value = value
  time:
    get: -> @uniforms.time.value
    set: (value) -> @uniforms.time.value = value
