app = require('app')

# Module to control application life.
BrowserWindow = require('browser-window')

# Module to create native browser window.
# Report crashes to our server.
# require('crash-reporter').start()

# Keep a global reference of the window object, if you don't, the window will
# be closed automatically when the javascript object is GCed.
mainWindow = null

# Quit when all windows are closed.
app.on 'window-all-closed', ->
  # On OSX it is common for applications and their menu bar
  # to stay active until the user quits explicitly with Cmd + Q
  if process.platform != 'darwin'
    app.quit()

# This method will be called when Electron has done everything
# initialization and ready for creating browser windows.
app.on 'ready', ->
  # Create the browser window.
  mainWindow = new BrowserWindow(
    title: 'Swim'
    frame: false
    "web-preferences":
      javascript: true
      "web-security": false
      images: true
      java: false
      "text-areas-are-resizable": false
      webgl: true
      webaudio: true
      plugins: false
      "experimental-features": true
      "experimental-canvas-features": true
  )

  mainWindow.maximize()
  mainWindow.setResizable false

  # and load the index.html of the app.
  mainWindow.loadUrl 'file://' + __dirname + '/index.html'

  # Open the devtools.
  mainWindow.openDevTools()

  mainWindow.on 'close', ->
    console.log 'close'
    mainWindow.webContents.send 'unload'
    return true

  # Emitted when the window is closed.
  mainWindow.on 'closed', ->
    # Dereference the window object, usually you would store windows
    # in an array if your app supports multi windows, this is the time
    # when you should delete the corresponding element.
    mainWindow = null

  # app.on 'before-quit', ->
    # console.log "before-quit"

  mainWindow.webContents.on 'did-finish-load', ->
    console.log 'did-finish-load'
    mainWindow.webContents.send 'load'
