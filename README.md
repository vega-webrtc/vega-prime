# Vega Prime

Vega Prime is a JavaScript package that provides a simple
interface for managing peer-to-peer media streams in UIs.
Use it in conjunction with the signaling server:
[Vega Server](https://github.com/davejachimiak/vega_server).

## Usage

### Example

Given a Vega Server running on port 9292 at http://www.example.org,
the following would produce the simplest video chat application.

```html
<html>
  <head>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
    <script src="/javascripts/vega-prime.bundle.js"></script>
  </head>
  
  <body>
    <div id="peers"></div>
    <video id="local-stream" autoplay muted></video>

    <div id="errors"></div>

    <script>
      new VegaPrime({
        url: 'ws://www.example.org:9292', 
        badge: { name: 'Dave' },
        roomId: 'a',
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

### API

#### `#onStreamAdded`

This is triggered when a peer in your room has established a
peer-to-peer stream. The callback is passed a peer object that
contains a `peerId`, a `stream`, a `streamUrl`, and a `badge`.
