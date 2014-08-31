// Generated by CoffeeScript 1.7.1
(function() {
  var VegaObservatory, VegaPrime,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  VegaObservatory = require('../vega-observatory');

  VegaPrime = (function() {
    function VegaPrime(options) {
      this.options = options;
      this.getUserMediaPromiseReject = __bind(this.getUserMediaPromiseReject, this);
      this.getUserMediaPromiseDone = __bind(this.getUserMediaPromiseDone, this);
      this.observatory = this.options.observatory || new VegaObservatory({
        url: this.options.url,
        roomId: this.options.roomId,
        badge: this.options.badge,
        localStream: this.options.localStream,
        peerConnectionConfig: this.options.peerConnectionConfig
      });
      this.getUserMediaPromise = this.options.getUserMediaPromise;
      this.callbacks = {};
      this._setObservatoryCallbacks();
    }

    VegaPrime.prototype.init = function() {
      var promise;
      promise = this.getUserMediaPromise.create();
      promise.done(this.getUserMediaPromiseDone);
      return promise.reject(this.getUserMediaPromiseReject);
    };

    VegaPrime.prototype.getUserMediaPromiseDone = function(stream) {
      var wrappedStream;
      wrappedStream = this._wrappedStream(stream);
      this.observatory.call(stream);
      return this.trigger('localStreamReceived', wrappedStream);
    };

    VegaPrime.prototype._wrappedStream = function(stream) {
      var url;
      url = URL.createObjectURL(stream);
      return {
        stream: stream,
        url: url
      };
    };

    VegaPrime.prototype.getUserMediaPromiseReject = function(error) {
      return this.trigger('localStreamError', error);
    };

    VegaPrime.prototype.onStreamAdded = function(f) {
      this.observatory.onStreamAdded(f);
      return this;
    };

    VegaPrime.prototype.onPeerRemoved = function(f) {
      this.observatory.onPeerRemoved(f);
      return this;
    };

    VegaPrime.prototype.onLocalStreamReceived = function(f) {
      this.on('localStreamReceived', f);
      return this;
    };

    VegaPrime.prototype._setObservatoryCallbacks = function() {
      this.observatory.on('callAccepted', (function(_this) {
        return function(peers) {
          return peers.forEach(function(peer) {
            return _this.observatory.createOffer(peer.peerId);
          });
        };
      })(this));
      return this.observatory.on('offer', (function(_this) {
        return function(payload) {
          return _this.observatory.createAnswer(payload.peerId);
        };
      })(this));
    };

    VegaPrime.prototype.on = function(event, callback) {
      var _base;
      (_base = this.callbacks)[event] || (_base[event] = []);
      return this.callbacks[event].push(callback);
    };

    VegaPrime.prototype.trigger = function(event) {
      var args, callbacks;
      args = Array.prototype.slice.call(arguments, 1);
      if (callbacks = this.callbacks[event]) {
        return callbacks.forEach(function(callback) {
          return callback.apply(this, args);
        });
      }
    };

    return VegaPrime;

  })();

  module.exports = VegaPrime;

}).call(this);
