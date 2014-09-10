# Vega Prime

Vega Prime is a JavaScript package that provides a simple
interface for managing peer-to-peer media streams in UIs.
Use it in conjunction with the signaling server:
[Vega Server](https://github.com/davejachimiak/vega_server).

## Usage

### Example

Given a Vega Server running on port 9292 at http://www.example.org and
the Vega Prime bundle located at the root of your application,
the following would produce the simplest video chat application.

```html
<html>
  <head>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
    <script src="vega-prime.bundle.js"></script>
  </head>
  
  <body>
    <div id="peers"></div>
    <video id="local-stream" autoplay muted></video>
    <div id="errors"></div>

    <script>
      new VegaPrime({
        url: 'ws://www.example.org:9292', 
        badge: { name: 'Dave' },
        roomId: 'some-room-id',
      }).onLocalStreamReceived(function(wrappedStream){
        $('video#local-stream').attr('src', wrappedStream.url);
      }).onStreamAdded(function(peer){
        $video = $('<video autoplay>');
        $video.attr('src', peer.streamUrl);
        $video.attr('data-peer-id', peer.peerId);

        $('#peers').append($video)
      }).onPeerRemoved(function(peer){
        $('video[data-peer-id="' + peer.peerId + '"]').remove()
      }).onClientWebsocketError(function(error){
        $('#errors').append(error);
      })
    </script>
  </body>
</html>
```

### Public API

#### Callback argument objects

##### Wrapped stream

Wrapped streams are simple objects with `stream` and `streamUrl` properties.
The value of the `stream` property is a [`MediaStream`](http://www.w3.org/TR/mediacapture-streams/#idl-def-MediaStream)
object. The value of the `streamUrl` property is a url string with which you can set
the `src` property of a video tag to display the local video feed.

```javascript
{ stream: MediaStream, streamUrl: "a blob url representing the stream" }
```

Callbacks passed to `#onLocalStreamReceived` are called with a wrapped stream.

##### Peers

Peers are simple objects with `badge`, `peerId`, `stream`,
and `streamUrl` properties. The value of the `badge` property
is the peer's [badge](link to badge). The value of the `peerId`
is a unique id given to the peer by the Vega Server. The value of the
`stream` property is a [`MediaStream`](http://www.w3.org/TR/mediacapture-streams/#idl-def-MediaStream)
object. The value of the `streamUrl` property is a url string with
which you can set the `src` property of a video tag to display the
peer's video feed.

```javascript
{ badge: Object,
  peerId: "a peer id",
  stream: MediaStream,
  streamUrl: "a blob url representing the stream" }
```

Callbacks passed to `#onStreamAdded` and `#onPeerRemoved` are called
with a peer.

#### Methods

The following methods can be chained together;
they return the VegaPrime instance.

##### Constructor

*To do*

##### `#onLocalStreamReceived(callback)`

This sets a callback that is triggered when the local media
(video/audio) stream is received by the browser. The callback
is called with a wrapped stream.

##### `#onStreamAdded`

This is triggered when a peer in your room has established a
peer-to-peer stream. The callback is passed a peer object that
contains a `peerId`, a `stream`, a `streamUrl`, and a `badge`.

## Internals 
