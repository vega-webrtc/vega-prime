VegaObservatory = require('../vega-observatory')

class VegaPrime
  constructor: (@options) ->
    @observatory = @options.observatory ||
      new VegaObservatory
        url: @options.url
        roomId: @options.roomId
        badge: @options.badge
        peerConnectionConfig: @options.peerConnectionConfig

    @getUserMedia = @options.getUserMedia || require('get-user-media')

    @userMediaConstraints = @options.userMediaConstraints ||
      video: true
      audio: true
    @callbacks = {}

    @_setObservatoryCallbacks()
    setTimeout @init, 0

  onStreamAdded: (f) ->
    @observatory.onStreamAdded(f)
    this

  onPeerRemoved: (f) ->
    @observatory.onPeerRemoved(f)
    this

  onLocalStreamReceived: (f) ->
    @on 'localStreamReceived', f
    this

  onClientWebsocketError: (f) ->
    @observatory.on 'clientWebsocketError', f
    this

  init: =>
    @getUserMedia(@userMediaConstraints, @getUserMediaCallback)

  getUserMediaCallback: (error, stream) =>
    if error
      @_localStreamError error
    else
      @_localStreamReceived stream

  _localStreamReceived: (stream) =>
    wrappedStream = @_wrappedStream stream

    @observatory.call(stream)
    @trigger 'localStreamReceived', wrappedStream

  _wrappedStream: (stream) ->
    url = URL.createObjectURL stream
    
    { stream: stream, url: url }

  _localStreamError: (error) =>
    @trigger 'localStreamError', error

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
