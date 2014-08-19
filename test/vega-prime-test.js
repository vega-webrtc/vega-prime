// Generated by CoffeeScript 1.7.1
(function() {
  var MockObservatory, VegaPrime, chai, expect, sinon, sinonChai;

  chai = require('chai');

  sinon = require('sinon');

  sinonChai = require('sinon-chai');

  expect = chai.expect;

  chai.use(sinonChai);

  VegaPrime = require('../vega-prime');

  MockObservatory = (function() {
    function MockObservatory() {}

    MockObservatory.prototype.callbacks = {};

    MockObservatory.prototype.on = function(event, callback) {
      var _base;
      (_base = this.callbacks)[event] || (_base[event] = []);
      return this.callbacks[event].push(callback);
    };

    MockObservatory.prototype.trigger = function(event) {
      var args, callbacks;
      args = Array.prototype.slice.call(arguments, 1);
      if (callbacks = this.callbacks[event]) {
        return callbacks.forEach(function(callback) {
          return callback.apply(this, args);
        });
      }
    };

    MockObservatory.prototype.call = function() {};

    MockObservatory.prototype.createOffer = function() {};

    MockObservatory.prototype.createAnswer = function() {};

    return MockObservatory;

  })();

  describe('vega-prime', function() {
    beforeEach(function() {
      var options;
      this.url = 'ws:0.0.0.0:3000';
      this.roomId = '/abc123';
      this.badge = {
        name: 'Dave'
      };
      this.observatory = new MockObservatory;
      options = {
        url: this.url,
        roomId: this.roomId,
        badge: this.badge,
        observatory: this.observatory
      };
      return this.vegaPrime = new VegaPrime(options);
    });
    afterEach(function() {
      return sinon.collection.restore();
    });
    describe('#init', function() {
      return it('orders the vega observatory to make a call', function() {
        var call;
        call = sinon.collection.stub(this.observatory, 'call');
        this.vegaPrime.init();
        return expect(call).to.have.been.called;
      });
    });
    return describe('observatory callbacks', function() {
      beforeEach(function() {
        var peer2;
        this.peer1 = {
          peerId: 'peerId1'
        };
        peer2 = {
          peerId: 'peerId2'
        };
        return this.peers = [this.peer1, peer2];
      });
      it('creates an offer for all peers in the payload', function() {
        var createOffer;
        createOffer = sinon.collection.spy(this.observatory, 'createOffer');
        this.observatory.trigger('callAccepted', this.peers);
        return this.peers.forEach((function(_this) {
          return function(peer) {
            return expect(createOffer).to.have.been.calledWith(peer.peerId);
          };
        })(this));
      });
      return it('creates an answer for an offering peer', function() {
        var createAnswer;
        createAnswer = sinon.collection.spy(this.observatory, 'createAnswer');
        this.observatory.trigger('offer', this.peer1);
        return expect(createAnswer).to.have.been.calledWith(this.peer1.peerId);
      });
    });
  });

}).call(this);
