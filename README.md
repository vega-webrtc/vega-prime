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

#### Constructor

An object must be passed to the constructor.
The `url`, `roomId`, and `badge` are mandatory
properties, while `peerConnectionConfig` is optional.

##### `url`

This must be the url of your Vega Server.

##### `roomId`

This must be a string. Peers of equal room ids
will be joined in a "room" and their media streams will be shared.

It's up to your application to decide how users get the same `roomId`.
You may want all users to be in the same room. Or you may want to give
a group of users a different `roomId` than another group of users.
Or you may want to let users choose what their room is called and
redirect to url with that name in a parameter so that they can share that
link (and, therefore, room) with other users with which they want
to chat.

In any case, it's up to your application what the `roomId` will be.

###### `badge`

This must be an object. It's meant to share identifying information
with peers. It's form should be consistent across your application so
that peers can reliably access each other's information and deal with it as
they like. For example, your application may want to display a peer's
name next to their video stream. Or, it may want to record that a stream
was established between users in the application's database.

#### Methods

The following methods can be chained together;
they return the VegaPrime instance.

##### `#onLocalStreamReceived(callback)`

This sets a callback that is triggered when the local media
(video/audio) stream is received by the browser. The callback
is called with a [wrapped stream](https://github.com/davejachimiak/vega-prime#wrapped-stream).

##### `#onStreamAdded`

This sets a callback that is triggered when a peer-to-peer
media stream has been established with a peer in the room.
The callback is called with a [peer](https://github.com/davejachimiak/vega-prime#peer)
object of the peer whose stream was added.

##### `#onPeerRemoved`

This sets a callback that is triggered when a peer leaves the
room. The callback is called with a peer object of the peer
that left the room.

##### `#onClientWebsocketError`

This sets a callback that is triggered if there is some error
in the Websocket connection to the Vega Server in
[Vega Client](https://github.com/davejachimiak/vega-client).

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

##### Peer

Peers are simple objects with `badge`, `peerId`, `stream`,
and `streamUrl` properties. The value of the `badge` property
is the peer's [badge](https://github.com/davejachimiak/vega-prime#badge).
The value of the `peerId` is a unique id given to the peer by the Vega Server.
The value of the `stream` property is a
[`MediaStream`](http://www.w3.org/TR/mediacapture-streams/#idl-def-MediaStream)
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

## Internals 

*To do*
