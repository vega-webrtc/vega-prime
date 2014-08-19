VegaObservatory = require('../vega-observatory')

class VegaPrime
  constructor: (@options) ->
    @observatory = @options.observatory ||
      new VegaObservatory
        url: @options.url
        roomId: @options.roomId
        badge: @options.badge

      @_setCallbacks()

  init: ->
    @observatory.call()

  _setCallbacks: ->
    @observatory.on 'callAccepted', (peers) =>
      peers.forEach (peer) =>
        @observatory.createOffer peer.peerId

module.exports = VegaPrime
