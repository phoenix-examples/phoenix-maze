/**
 * Wrapper for WebSocket functionality
 *
 * @author Rob Hawkes
 * @requires io.Socket
 */

/**
 * @constructor
 */
var Socket = function(player_id) {
	//this.socket = new WebSocket("ws://socket.rawkets.com:8000"); // Testing new server with port 8000 socket connection
	
	//return this.socket;

  var socket = new Phoenix.Socket("/ws", {params: {user_id: player_id}});
  socket.connect();

  this.socket = socket.chan("rawkets:game", {});
  return this.socket;
};
