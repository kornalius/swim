{ Plugin, EventEmitter, bos, qry, fs, path, cson } = Swim

ObjectExtender =

  store: (path, cb) ->
    if @_store?
      @_store.close()
      @_storepath = null
      @_store = null
    bos path, defaultObject: @valueOf(), (error, store) ->
      if error?
        throw error
      @_store = store
      @_storepath = path
    .on 'error', (error) ->
      console.error(error)

  query: (q) -> qry q, @valueOf()

  compact: -> _.compactObject @valueOf()

  clone: (deep) -> _.clone @valueOf(), deep

  mixin: (deep) -> if deep then _.deepExtend @valueOf() else _.extend @valueOf()

  renameKeys: (keys) -> _.renameKeys @valueOf(), keys

  selectKeys: (keys) -> _.selectKeys @valueOf(), keys

  kv: (key) -> _.kv @valueOf(), key

  isArray: -> _.isArray @valueOf()

  isBoolean: -> _.isBoolean @valueOf()

  isDate: -> _.isDate @valueOf()

  isEmpty: -> _.isEmpty @valueOf()

  isError: -> _.isError @valueOf()

  isFunction: -> _.isFunction @valueOf()

  isNaN: -> _.isNaN @valueOf()

  isNull: -> _.isNull @valueOf()

  isUndefined: -> _.isUndefined @valueOf()

  isNumber: -> _.isNumber @valueOf()

  isObject: -> _.isObject @valueOf()

  isPlainObject: -> _.isPlainObject @valueOf()

  isRegExp: -> _.isRegExp @valueOf()

  isString: -> _.isString @valueOf()

  defaults: (sources...) -> _.defaultsDeep @valueOf(), sources...

  p: (path, value) -> if value? then _.set @valueOf(), path, value else _.get @valueOf(), path

  has: (path) -> _.has @valueOf(), path

  keys: -> _.keys @valueOf()

  values: -> _.values @valueOf()

  pairs: -> _.pairs @valueOf()

  functions: -> _.functions @valueOf()

  flatten: -> require('flat').flatten @valueOf(), overwrite: true

  unflatten: -> require('flat').unflatten @valueOf(), overwrite: true

  save: (path, cb) -> Swim.save(@valueOf(), cb)


for k, v of ObjectExtender
  Object.defineProperty Object.prototype, k, writable: true, configurable: true, enumerable: false, value: v
