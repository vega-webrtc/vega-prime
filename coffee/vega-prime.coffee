VegaObservatory = require('../vega-observatory')

class VegaPrime
  constructor: (@options) ->
    @observatory = @options.observatory ||
      new VegaObservatory
        url: @options.url
        roomId: @options.roomId
        badge: @options.badge
        localStream: @options.localStream

    @_setCallbacks()

  init: ->
    @observatory.call()

  onStreamAdded: (f) ->
    @observatory.onStreamAdded(f)

  onPeerRemoved: (f) ->
    @observatory.onPeerRemoved(f)

  _setCallbacks: ->
    @observatory.on 'callAccepted', (peers) =>
      peers.forEach (peer) =>
        @observatory.createOffer peer.peerId

    @observatory.on 'offer', (payload) =>
      @observatory.createAnswer payload.peerId

module.exports = VegaPrime
