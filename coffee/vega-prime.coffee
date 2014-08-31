VegaObservatory = require('../vega-observatory')

class VegaPrime
  constructor: (@options) ->
    @observatory = @options.observatory ||
      new VegaObservatory
        url: @options.url
        roomId: @options.roomId
        badge: @options.badge
        localStream: @options.localStream
        peerConnectionConfig: @options.peerConnectionConfig

    @getUserMediaPromise = @options.getUserMediaPromise
    @callbacks = {}

    @_setObservatoryCallbacks()

  init: ->
    promise = @getUserMediaPromise.create()
    promise.done @getUserMediaPromiseDone
    promise.reject @getUserMediaPromiseReject

  getUserMediaPromiseDone: (stream) =>
    @observatory.call(stream)

  onStreamAdded: (f) ->
    @observatory.onStreamAdded(f)
    this

  onPeerRemoved: (f) ->
    @observatory.onPeerRemoved(f)
    this

  onLocalStreamReceived: (f) ->
    @on 'localStreamReceived', f
    this

  _setObservatoryCallbacks: ->
    @observatory.on 'callAccepted', (peers) =>
      peers.forEach (peer) =>
        @observatory.createOffer peer.peerId

    @observatory.on 'offer', (payload) =>
      @observatory.createAnswer payload.peerId

  on: (event, callback) ->
    @callbacks[event] ||= []
    @callbacks[event].push callback

  trigger: (event) ->
    args = Array.prototype.slice.call(arguments, 1)

    if callbacks = @callbacks[event]
      callbacks.forEach (callback) ->
        callback.apply(this, args)

module.exports = VegaPrime
