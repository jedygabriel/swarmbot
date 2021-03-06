{ createProject } = require '../../helpers/test-helper'
{log, p, json} = require 'lightsaber'
Project = require '../../../src/models/project.coffee'
CreateView = require '../../../src/views/rewards/create-view.coffee'

describe 'Create View', ->
  describe 'rewardTypesMenu', ->
    it 'returns an empty string when there are no reward types or a list when there are', ->
      createProject()
      .then (@project)=>
        view = new CreateView(@project, {recipient: null}, {recipient: null})
        json(view.rewardTypesMenu()).should.match /No award types, please create one/
        @project.createRewardType(name: "Foo")
      .then (@rewardType)=>
        @project.fetch()
      .then (@project)=>
        view = new CreateView(@project, {recipient: null}, {recipient: null})
        json(view.rewardTypesMenu()).should.match /Foo/
