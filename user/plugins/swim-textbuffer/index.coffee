{ Plugin, $, path } = Swim

require('./textbuffer.coffee')
require('./textcursor.coffee')

module.exports =

  load: ->
    t = new Swim.TextBuffer "This is some text to test if this new \ntext buffer system is going \nto work well or not!\n"
    c = new Swim.TextCursor t, 0, 0
    c.moveToNextWord()
    c.insert "Insert some text here"
    console.log t.lines
    t.undo()
    console.log t.lines
    t.redo()
    console.log t.lines

  unload: ->
