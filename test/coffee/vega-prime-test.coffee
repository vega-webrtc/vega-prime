chai      = require('chai')
sinon     = require('sinon')
sinonChai = require('sinon-chai')
expect    = chai.expect

chai.use sinonChai

VegaPrime = require('../vega-prime')

class MockObservatory
  callbacks: {}

  on: (event, callback)->
    @callbacks[event] ||= []
    @callbacks[event].push callback

  trigger: (event) ->
    args = Array.prototype.slice.call(arguments, 1)

    if callbacks = @callbacks[event]
      callbacks.forEach (callback) ->
        callback.apply(this, args)

  call: ->
  createOffer: ->
  createAnswer: ->

describe 'vega-prime', ->
  beforeEach ->
    @url = 'ws:0.0.0.0:3000'
    @roomId = '/abc123'
    @badge = { name: 'Dave' }
    @observatory = new MockObservatory

    options =
      url: @url
      roomId: @roomId
      badge: @badge
      observatory: @observatory

    @vegaPrime = new VegaPrime options

  afterEach ->
    sinon.collection.restore()

  describe '#init', ->
    it 'orders the vega observatory to make a call', ->
      call = sinon.collection.stub @observatory, 'call'

      @vegaPrime.init()

      expect(call).to.have.been.called

  describe 'observatory callbacks', ->
    beforeEach ->
      @peer1 = { peerId: 'peerId1' }
      peer2 = { peerId: 'peerId2' }
      @peers = [@peer1, peer2]

    it 'creates an offer for all peers in the payload', ->
      createOffer = sinon.collection.spy @observatory, 'createOffer'

      @observatory.trigger 'callAccepted', @peers

      @peers.forEach (peer) =>
        expect(createOffer).to.have.been.calledWith peer.peerId

    it 'creates an answer for an offering peer', ->
      createAnswer = sinon.collection.spy @observatory, 'createAnswer'

      @observatory.trigger 'offer', @peer1

      expect(createAnswer).to.have.been.calledWith @peer1.peerId
