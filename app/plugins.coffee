Swim.loadedPlugins = []

packages = ->
  initPackageJson()
  pkg = JSON.parse(Swim.fs.readFileSync(Swim.dirs.user_pkg))
  r = if pkg? and pkg.dependencies? then pkg.dependencies else {}
  nr = []
  for n, v of r
    pn = Swim.path.join(Swim.dirs.user, v)
    fn = Swim.path.join(pn, n)
    nr.push
      name: n
      version: if Swim.fs.existsSync(fn) then '0.0.0' else v
      location: if Swim.fs.existsSync(fn) then pn else Swim.path.join(Swim.dirs.node_modules, n)
  return nr


plugins = (type) ->
  r = []
  if !type?
    for k, v of Swim.settings.get('plugins')
      r.push k
  else if type == 'e'
    for k, v of Swim.settings.get('plugins')
      if v
        r.push k
  else if type == 'd'
    for k, v of Swim.settings.get('plugins')
      if !v
        r.push k
  return r


findPackage = (name) ->
  for p in packages()
    if p.name == name
      return p
  return { name: null, plugin: false, version: null }


packagePath = (name) ->
  { name, version, location } = findPackage(name)
  if name? then Swim.path.join(location, name)


packageFile = (name) ->
  Swim.path.join(packagePath(name), 'package.json')


packageJson = (name) ->
  JSON.parse(Swim.fs.readFileSync(packageFile(name)))


mainPackageFile = (name) ->
  Swim.path.join(packagePath(name), packageJson(name).main)


initPackageJson = ->
  { fs } = Swim
  f = Swim.dirs.user_pkg
  if !fs.existsSync(f)
    fs.writeFileSync f, JSON.stringify(
      name: "my_yorkfire_setup"
      private: true
      dependencies: {}
    , null, '  ')


install = (names, cb) ->
  { npm } = Swim
  initPackageJson()
  if !names?
    names = []
  npm.load
    prefix: Swim.dirs.user
    save: true
  , ->
    npm.commands.install names, (err) ->
      throw err if err?
      cb(arguments) if cb?


uninstall = (names, cb) ->
  { npm, settings } = Swim
  initPackageJson()
  npm.load
    prefix: Swim.dirs.user
    save: true
  , ->
    npm.commands.uninstall names, (err) ->
      throw err if err?
      for n in names
        unload(n)
      cb(arguments) if cb?


installed = (name) ->
  findPackage(name).name?


loaded = (name) ->
  for p in Swim.loadedPlugins
    if p.name == name
      return p
  return null


load = (name, spaces) ->
  if name?
    if !spaces?
      spaces = ''
    if !loaded(name)
      if installed(name)
        m = require(mainPackageFile(name))
        if m?
          console.log "#{spaces}#{name} loaded"
          Swim.loadedPlugins.push
            module: m
            name: name
          m.load()
      else
        console.log "#{spaces}#{name} ** not installed"
    else
      console.log "#{spaces}#{name} ** already loaded"
  else
    console.log "Loading plugins..."
    for n in plugins('e')
      load(n, '  ')

  # paths = fs.listSync path.join(Swim.dirs.module, 'plugins'), ['coffee', 'js']
  # if paths?
  #   for f in paths
  #     p = new Plugin f, ->
  #       console.log "  #{p.name}#{if p.ignored then ' -- ignored --' else ''}"


unload = (name, spaces) ->
  if name?
    if !spaces?
      spaces = ''
    p = loaded(name)
    if p?
      console.log "#{spaces}#{name} unloaded"
      p.module.unload()
      _.remove(Swim.loadedPlugins, p)
    else
      console.log "#{spaces}#{name} ** not loaded"
  else
    console.log "Unloading plugins..."
    for p in Swim.loadedPlugins
      unload(p.name, '  ')


publish = (name) ->


create = (opts) ->
  { fs } = Swim
  fn = "swim-#{opts.name}"
  p = packagePath(fn)
  fs.mkdirSync(p)
  if !opts.main?
    opts.main = 'main.coffee'
  fs.writeFileSync packageFile(fn), JSON.stringify(opts, null, '  ')
  fs.writeFileSync mainPackageFile(fn), ''


module.exports =

  packages: packages
  findPackage: findPackage
  packagePath: packagePath
  packageFile: packageFile
  packageJson: packageJson
  initPackageJson: initPackageJson
  install: install
  uninstall: uninstall
  installed: installed
  loaded: loaded
  load: load
  unload: unload
  publish: publish
  create: create
  plugins: plugins

