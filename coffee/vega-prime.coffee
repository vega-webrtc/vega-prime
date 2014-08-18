VegaObservatory = require('../vega-observatory')

class VegaPrime
  constructor: (@options) ->
    @observatory = @options.observatory ||
      new VegaObservatory
        url: @options.url
        roomId: @options.roomId
        badge: @options.badge

  init: ->
    @observatory.call()

module.exports = VegaPrime
