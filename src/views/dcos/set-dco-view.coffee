{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class SetDcoView extends ZorkView

  constructor: (dcos) ->
    i = 0
    @menu = {}
    @menu[i++] = { text: "back", transition: 'exit' }
    for dco in dcos.all()
      @menu[i++] = @dcoMenuItem dco

    @menu[i++] = {
      text: "create new project"
      transition: 'create'
    }

  dcoMenuItem: (dco) ->
    {
      text: dco.get 'name'
      data: {id: dco.key(), name: dco.get('name')}
      command: 'setDcoTo'
    }

  render: ->
    fallbackText = """
    *Set Current Project*
    #{@renderMenu()}

    To take an action, simply enter the number or letter at the beginning of the line.
    """

    [
      {
        color: @NAV_COLOR
        title: "choose your project"
      }
      {
        color: @ACTION_COLOR
        fields: [
          {
            title: 'Actions'
            value: @renderMenu()
          }
        ]
        fallback: fallbackText
      }
    ]


module.exports = SetDcoView
