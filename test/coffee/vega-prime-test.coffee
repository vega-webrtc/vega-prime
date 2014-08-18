chai      = require('chai')
sinon     = require('sinon')
sinonChai = require('sinon-chai')
expect    = chai.expect

chai.use sinonChai

VegaPrime = require('../vega-prime')

describe 'vega-prime', ->
  beforeEach ->
    @url = 'ws:0.0.0.0:3000'
    @roomId = '/abc123'
    @badge = { name: 'Dave' }
    @observatory = call: ->
    options =
      url: @url
      roomId: @roomId
      badge: @badge
      observatory: @observatory

    @vegaPrime = new VegaPrime options

  describe '#init', ->
    it 'orders the vega observatory to make a call', ->
      call = sinon.collection.stub @observatory, 'call'

      @vegaPrime.init()

      expect(call).to.have.been.called
