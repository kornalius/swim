{ Plugin, $, path, Terminal, TermCursor, View } = Swim

Swim.Checkbox = class Checkbox extends View

  @::accessor 'checked',
    get: ->  @_checked
    set: (value) ->
      if @_checked != value
        @_checked = value
        @render()._update()

  @::accessor 'label',
    get: ->  @_label
    set: (value) ->
      if @_label != value
        @_label = value
        @_resize().render()._update()

  constructor: (config) ->
    super config
    @label = if config?.label? then config.label else "label"

  viewText: -> "#{if @_checked then @icon('check_box') else @icon('check_box_outline_blank')} #{if @_label? then @_label else 'label'}"

  onClick: (e) =>
    super e
    @checked = !@_checked
    s = @viewText()
    console.log s.charCodeAt(0).toString(16), s.charCodeAt(1).toString(16), s.charCodeAt(2).toString(16)
    e.stopPropagation()
