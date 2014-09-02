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
  onStreamAdded: ->
  onPeerRemoved: ->

describe 'vega-prime', ->
  beforeEach ->
    @url = 'ws://0.0.0.0:3000'
    @roomId = '/abc123'
    @badge = { name: 'Dave' }
    @observatory = new MockObservatory
    @getUserMedia = ->
    @userMediaConstraints = new Object

    options =
      url: @url
      roomId: @roomId
      badge: @badge
      observatory: @observatory
      getUserMedia: @getUserMedia
      userMediaConstraints: @userMediaConstraints

    @setTimeout = sinon.collection.stub global, 'setTimeout'

    @vegaPrime = new VegaPrime options

  afterEach ->
    sinon.collection.restore()

  describe 'new', ->
    it 'asynchronously calls init', ->
      expect(@setTimeout).to.have.been.calledWith @vegaPrime.init, 0

  describe '#init', ->
    beforeEach ->
      @stub = sinon.collection.stub(@vegaPrime, 'getUserMedia')

    it 'calls getUserMedia with constraints and callback', ->
      @vegaPrime.init()

      expect(@stub).to.have.been.calledWith @userMediaConstraints,
        @vegaPrime.getUserMediaCallback

  describe '#getUserMediaCallback', ->
    describe 'an error occurred', ->
      it 'delegates to localStreamError', ->
        localStreamError = sinon.collection.stub @vegaPrime, '_localStreamError'

        @vegaPrime.getUserMediaCallback error = new Object, null

        expect(localStreamError).to.have.been.calledWith error

    describe 'stream is passed', ->
      it 'delegates to _localStreamReceived', ->
        localStreamReceived = sinon.collection.stub @vegaPrime, '_localStreamReceived'

        @vegaPrime.getUserMediaCallback null, stream = new Object

        expect(localStreamReceived).to.have.been.calledWith stream

  describe '#_localStreamReceived', ->
    beforeEach ->
      @stream  = new Object
      @call    = sinon.collection.stub @observatory, 'call'
      @trigger = sinon.collection.stub @vegaPrime, 'trigger'
      sinon.collection.stub(@vegaPrime, '_wrappedStream').
        withArgs(@stream).
        returns @wrappedStream = new Object

      @vegaPrime._localStreamReceived(@stream)

    it 'has the observatory make a call with the local stream', ->
      expect(@call).to.have.been.calledWith @stream

    it 'triggers localStreamReceived with a wrapped stream', ->
      expect(@trigger).to.have.been.calledWith 'localStreamReceived', @wrappedStream

  describe '_wrappedStream', ->
    it 'creates an object url out of the stream and sets it with the stream on an object', ->
      stream = new Object
      global.URL = urlHelper = createObjectURL: ->
      sinon.collection.stub(urlHelper, 'createObjectURL').
        withArgs(stream).
        returns url = 'http://www..com'

      expect(@vegaPrime._wrappedStream(stream)).to.eql
        stream: stream
        url: url

      global.URL = undefined

  describe '#_localStreamError', ->
    it 'triggers a localStreamError', ->
      trigger = sinon.collection.stub @vegaPrime, 'trigger'
      error   = new Object

      @vegaPrime._localStreamError error

      expect(trigger).to.have.been.calledWith 'localStreamError', error

  describe '#onStreamAdded', ->
    it 'delegates to the observatory', ->
      onStreamAdded = sinon.collection.stub @observatory, 'onStreamAdded'
      arg = ->

      @vegaPrime.onStreamAdded(arg)

      expect(onStreamAdded).to.have.been.calledWith(arg)

    it 'returns vega prime', ->
      returnVal = @vegaPrime.onStreamAdded(->)

      expect(returnVal).to.eq @vegaPrime

  describe '#onPeerRemoved', ->
    it 'delegates to the observatory', ->
      onPeerRemoved = sinon.collection.stub @observatory, 'onPeerRemoved'
      arg = ->

      @vegaPrime.onPeerRemoved(arg)

      expect(onPeerRemoved).to.have.been.calledWith(arg)

    it 'returns vega prime', ->
      returnVal = @vegaPrime.onPeerRemoved(->)

      expect(returnVal).to.eq @vegaPrime

  describe '#onLocalStreamReceived', ->
    it 'saves a callback for when a local stream is received', ->
      stream = new Object
      callback = (stream) =>
        @theStream = stream

      @vegaPrime.onLocalStreamReceived(callback)
      @vegaPrime.trigger 'localStreamReceived', stream

      expect(@theStream).to.eq stream

    it 'returns the vega prime', ->
      returnVal = @vegaPrime.onLocalStreamReceived(->)

      expect(returnVal).to.eq @vegaPrime

  describe '#onClientWebsocketError', ->
    it 'sets the on the observatory event listeners', ->
      oN = sinon.collection.stub @observatory, 'on'

      @vegaPrime.onClientWebsocketError(f = ->)

      expect(oN).to.have.been.calledWith 'clientWebsocketError', f

    it 'returns the vega prime object', ->
      value = @vegaPrime.onClientWebsocketError(f = ->)

      expect(value).to.eq @vegaPrime

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
