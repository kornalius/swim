spawn           = require('child_process').spawn
exec            = require('child_process').exec
bl              = require('bl')
through2        = require('through2')

defaultFormat   = 'html'
defaultLang     = 'js'
defaultEncoding = 'utf8'

pythonVersions = {}

fromString = (child, code, callback) ->
  stdout = bl()
  stderr = bl()
  ec     = 0

  exitClose = ->
    return if ++ec < 2
    callback(null, stdout.slice())

  child.stdout.pipe(stdout)
  child.stderr.pipe(stderr)

  child.on('exit', (code) ->
    if code != 0
      ec = -1
      return callback(new Error('Error calling `pygmentize`: ' + stderr.toString()))
    exitClose()
  )

  child.on('close', exitClose)

  child.stdin.write(code)
  child.stdin.end()

fromStream = (retStream, intStream, child) ->
  stderr    = bl()
  outStream = through2((chunk, enc, callback) ->
    retStream.__write(chunk, enc, callback)
  )

  intStream.pipe(child.stdin)
  child.stdout.pipe(outStream)
  child.stderr.pipe(stderr)

  child.on('exit', (code) ->
    if code != 0
      retStream.emit('error', stderr.toString())
    retStream.__end()
  )

pygmentize = (options, code, callback) ->
  options = options || {}

  execArgs = [
          '-f', options.format || defaultFormat
        , '-l', options.lang || defaultLang
        , '-P', 'encoding=' + options.encoding if options.encoding?
      ]
  toString  = _.isString(code) && _.isFunction(callback)
  retStream = if !toString? then through2() else null
  intStream = if !toString? then through2() else null

  if typeof options.options == 'object'
    for key in _.keys(options.options)
      execArgs.push('-P', key + '=' + options.options[key])

  spawnPygmentize(options, execArgs, (err, child) ->
    if toString?
      return callback(err) if err?
      return fromString(child, code, callback)

    return retStream.emit('error', err) if err?

    fromStream(retStream, intStream, child)
  )

  if retStream?
    retStream.__write = retStream.write
    retStream.write = intStream.write.bind(intStream)
    retStream.__end = retStream.end
    retStream.end = intStream.end.bind(intStream)

  return retStream

spawnPygmentize = (options, execArgs, callback) ->
  python = if _.isString(options.python) then options.python else 'python'

  pythonVersion(python, (err, version) ->
    return callback(err) if err?

    return callback(new Error('Unsupported Python version: ' + version)) if version != 2 && version != 3

    pyg = path.join(
      __dirname,
      'pygments',
      (if version == 2 then 'build-2.7' else 'build-3.3'),
      'pygmentize'
    )

    callback(null, spawn(python, [pyg].concat(execArgs)))
  )

pythonVersion = (python, callback) ->
  if pythonVersions[python]?
    return callback(null, pythonVersions[python])

  exec(python + ' -V', (err, stdout, stderr) ->
    return callback(err) if err?

    m = stderr.toString().match(/^Python (\d)[.\d]+/i)
    if !m?
      m = stdout.toString().match(/^Python (\d)[.\d]+/i)
    if !m?
      return callback(new Error('Cannot determine Python version: [' + stderr.toString() + ']'))

    pythonVersions[python] = +m[1]

    return callback(null, +m[1])
  )


pygmentize({ lang: 'js', format: 'raw' }, 'var a = "b";', (err, result) ->
  if !err?
    tokens = []
    lines = result.toString().split('\n')
    for l in lines
      [type, value] = l.split('\t')
      if type? and type != "" and value?
        tokens.push type: type, value: value.substr(2, value.length - 3)
  console.log tokens
)
