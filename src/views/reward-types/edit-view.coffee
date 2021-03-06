{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class EditView extends ZorkView
  constructor: (@data)->
    @menu = {}
    @menu.x = { text: "Back", transition: 'exit', data: {rewardTypeId: @data.rewardTypeId} }

  render: ->
    @question "Enter the bounty amount ('x' to exit)"

module.exports = EditView
