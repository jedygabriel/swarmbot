{ createUser, createProject } = require '../helpers/test-helper'
{ p } = require 'lightsaber'
sinon = require 'sinon'
Keen = require 'keen-js'
KeenioInfo = require '../../src/services/keenio-info.coffee'

describe 'Keenio', ->
  beforeEach ->
    @keenioClient = {addEvent: sinon.spy()}
    @keenioInfo = new KeenioInfo(@keenioClient)
    # Keenio::getAssetInfo.restore?()

  afterEach ->

  describe '.createUser', ->
    it 'calls out to keenio with the right parameters', ->
      createUser
        slackUsername: 'bob'
        emailAddress: 'bob@example.com'
      .then (user)=>
        @keenioInfo.createUser user
        @keenioClient.addEvent.should.have.been.calledWith(
          'createUser',
          slackUsername: 'bob'
          emailAddress: 'bob@example.com'
        )
