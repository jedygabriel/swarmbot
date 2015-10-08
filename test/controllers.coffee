{log, p, pjson} = require 'lightsaber'
Helper = require 'hubot-test-helper'
Promise = require('bluebird')

chai = require 'chai'
chaiAsPromised = require("chai-as-promised")
chai.should()
chai.use(chaiAsPromised);
sinon = require 'sinon'
require('sinon-as-promised')(Promise)
require 'sinon-chai'

FirebaseModel = require '../src/models/firebase-model'
User = require '../src/models/user'
DCO = require '../src/models/dco'
ApplicationController = require '../src/controllers/application-controller'
UsersController = require '../src/controllers/users-controller'
ProposalsStateController = require '../src/controllers/proposals-state-controller'

process.env.EXPRESS_PORT = 8901  # don't conflict with hubot console port 8080
# process.env.FIREBASE_URL = 'https://dazzle-staging.firebaseio-demo.com/'

helper = new Helper '../src/bots'

describe 'controllers', ->
  before ->
    sinon.stub FirebaseModel.prototype, "save", sinon.stub().resolves()

  beforeEach -> @room = helper.createRoom()
  afterEach -> @room.destroy()

  context 'ProposalsStateController', ->
    context "state: proposals", ->
      it "calls show from the 1 command and transitions state", ->
        router = {route: ->}
        user = new User(id: 'x', state: 'home')
        user.current = 'home'
        msg = { match: [ 'swarmbot 1', '1' ], currentUser: user }

        new ProposalsStateController(router, msg).process()
        user.current.should.eq 'proposals-show'

  context 'ApplicationController', ->
    beforeEach ->
      @controller = new ApplicationController()

    context 'getDco()', ->
      beforeEach ->
        @user = new User(id: 'henry')
        sinon.stub @user, "fetch", sinon.stub().resolves(@user)
        sinon.stub @controller, "currentUser", => @user

      it 'gets the community if it\'s set on the controller', ->
        @controller.community = 'xyz'
        @controller.getDco().then((dco)-> dco.get('id')).should.eventually.equal 'xyz'

      it "gets the community if it's the user's current community", ->
        @user.attributes.current_dco = 'zzz'
        @controller.getDco().then((dco)-> dco.get('id')).should.eventually.equal 'zzz'

      it "rejects the promise with an error if the user has no community.", ->
        @controller.getDco().should.be.rejected

  context 'UsersController', ->

    beforeEach ->
      @user = new User(id: 'henry')
      @controller = new UsersController()
      sinon.stub @controller, "currentUser", => @user

    context 'register()', ->
      xit 'registers a user\'s information', ->
        fetch = sinon.stub().resolves(@user)
        sinon.stub @user, "fetch", fetch
        @room.message =
          user:
            id: 123
            real_name: 'George'
            email_address: 'porgey@puddinpie.com'
        @controller.register(@room).then =>
          console.log @room.messages

    context 'registerBtc()', ->
      it 'allows user to register a bitcoin address', ->
        btcAddress = '12afeafeaefeaee'
        sinon.mock(@user).expects("set").withArgs("btc_address", btcAddress)
        @controller.registerBtc @room, {btcAddress}

    context 'setCommunity()', ->
      it 'sets the DCO on a user', ->
        community = "have-fun"
        sinon.mock(@user).expects("setDco").withArgs(community)
        @controller.setCommunity(@room, { community })
