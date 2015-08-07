r = require('remote')
a = r.require('app')
p = r.require('path')
ipc = require('ipc')

PropertyAccessors = require 'property-accessors'

userPath = p.join(a.getPath('home'), '.swim')

if !window.$?
  window.$ = require('cash-dom')

if !window._?
  window._ = require('underscore-plus')

  _.extend _,
    uncapitalize: (str) ->
      return str[0].toLowerCase() + str.slice(1)

  _.is = require('is')
  _.extend(_, require('underscore-contrib'))
  _.extend(_, require('starkjs-underscore'))
  _.number = require('underscore.number')
  _.array = require('underscore.array')

npm = require('npm')

if !window.Swim?
  window.Swim =
    remote: r
    app: a
    BrowserWindow: r.require('browser-window')
    appWindow: r.getCurrentWindow()
    dirs:
      home: a.getPath('home')
      app: a.getPath('appData')
      user: userPath
      tmp: a.getPath('temp')
      root: a.getPath('exe')
      module: p.dirname(module.filename)
      node_modules: p.join(userPath, 'node_modules')
      user_pkg: p.join(userPath, 'package.json')
    async: r.require 'async'
    PropertyAccessors: require 'property-accessors'
    fs: r.require 'fs-plus'
    path: p
    ipc: ipc
    cson: require 'cson-parser'
    npm: npm
    buffer: r.require 'buffer'
    child_process: r.require 'child_process'
    events: r.require 'events'
    domain: r.require 'domain'
    http: r.require 'http'
    https: r.require 'https'
    os: r.require 'os'
    stream: r.require 'stream'
    tls: r.require 'tls'
    url: r.require 'url'
    vm: r.require 'vm'
    zlib: r.require 'zlib'
    util: r.require 'util'

  _.extend Swim,
    settings: require('./settings.coffee')
    plugins: require('./plugins.coffee')


# Make sure home Swim directory exists
if !Swim.fs.existsSync(userPath)
  Swim.fs.mkdirSync(userPath)

console.log "Booting #{a.getName()} v#{a.getVersion()}..."
console.log "io.js: #{process.version}"
console.log "Electron: #{process.versions['electron']}"
console.log ""
console.log "Root path: #{Swim.dirs.root}"
console.log "Module path: #{Swim.dirs.node_modules}"
console.log "Temp path: #{Swim.dirs.tmp}"
console.log "App path: #{Swim.dirs.app}"
console.log "User path: #{Swim.dirs.user}"
console.log "Home path: #{Swim.dirs.home}"


ipc.on 'load', ->
  window.Swim.PIXI = PIXI

  Swim.PIXI.Point.prototype.distance = (target) ->
    Math.sqrt((@x - target.x) * (@x - target.x) + (@y - target.y) * (@y - target.y))

  Swim.PIXI.Point.prototype.toString = ->
    "(#{@x}, #{@y})"

  Swim.PIXI.Rectangle.prototype.toString = ->
    "(#{@x}, #{@y}, #{@x + @width}, #{@y + @height})(#{@width}, #{@height})"

  w = document.documentElement.clientWidth
  h = document.documentElement.clientHeight

  Swim.renderer = new PIXI.WebGLRenderer w, h
  document.body.appendChild Swim.renderer.view
  Swim.stage = new PIXI.Container()
  # Swim.stage.interactive = true

  Swim.settings.load (err) ->
    # York.plugins.install ['async'], (err) ->
    Swim.plugins.load()


ipc.on 'unload', ->
  Swim.settings.saveSync()

  Swim.plugins.unload()

  Swim.stage.destroy()
  Swim.stage = null

  Swim.renderer.destroy()
  Swim.renderer = null

