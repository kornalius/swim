{ Plugin } = Swim

Array.prototype.cat = (values...) -> _.each values, ((v) -> @push v).bind(@)

Array.prototype.each = (iteratee, thisArg) -> _.each @valueOf(), iteratee, thisArg

Array.prototype.sum = (values...) -> r = 0; values.each (v) -> r += v; r

Array.prototype.average = (values...) -> @sum(@valueOf(), values...) / @length

Array.prototype.chunk = (size = 1) -> _.chunk @valueOf(), size

Array.prototype.difference = (arrays...) -> _.difference @valueOf(), arrays...

Array.prototype.fill = (value, start = 0, end = @valueOf().length) -> _.fill @valueOf(), value, start, end

Array.prototype.first = -> _.first @valueOf()

Array.prototype.last = -> _.last @valueOf()

Array.prototype.flatten = -> _.flatten @valueOf(), true

Array.prototype.find = (value, fromIndex = 0) -> _.indexOf @valueOf(), value, fromIndex

Array.prototype.findLast = (value, fromIndex = 0) -> _.lastIndexOf @valueOf(), value, fromIndex

Array.prototype.remove = (values...) -> _.pull @valueOf(), values...

Array.prototype.removeAt = (indexes...) -> _.pullAt @valueOf(), indexes...

Array.prototype.rest = -> _.rest @valueOf()

Array.prototype.slice = (start = 0, end = @valueOf().length) -> _.slice @valueOf(), start, end

Array.prototype.take = (n = 1) -> _.take @valueOf(), n

Array.prototype.takeRight = (n = 1) -> _.takeRight @valueOf(), n

Array.prototype.union = (arrays...) -> _.union @valueOf(), arrays...

Array.prototype.without = (values...) -> _.without @valueOf(), values...

Array.prototype.xor = (arrays...) -> _.xor @valueOf(), arrays...

Array.prototype.min = (iteratee, thisArg) -> _.min @valueOf(), iteratee, thisArg

Array.prototype.max = (iteratee, thisArg) -> _.max @valueOf(), iteratee, thisArg

# Array.prototype.map = (iteratee = _.identity, thisArg) -> _.map @valueOf(), iteratee, thisArg

Array.prototype.shuffle = -> _.shuffle @valueOf()

Array.prototype.every = (predicate = _.identity, thisArg) -> _.every @valueOf(), predicate, thisArg

Array.prototype.some = (predicate = _.identity, thisArg) -> _.some @valueOf(), predicate, thisArg

Array.prototype.reduce = (iteratee = _.identity, accumulator, thisArg) -> _.reduce @valueOf(), iteratee, accumulator, thisArg

Array.prototype.reduceRight = (iteratee = _.identity, accumulator, thisArg) -> _.reduceRight @valueOf(), iteratee, accumulator, thisArg

