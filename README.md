# Vega Prime

Vega Prime is a JavaScript package that provides a simple
interface for managing peer-to-peer media streams in UIs.
Use it in conjunction with the signaling server:
[Vega Server](https://github.com/davejachimiak/vega_server).

## Usage

### Interface

#### `#onStreamAdded`

This is triggered when a peer in your room has established a
peer-to-peer stream. The callback is passed a peer object that
contains a `peerId`, a `stream`, a `streamUrl`, and a `badge`.
