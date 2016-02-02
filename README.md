# Streamit
Turn any subreddit into a real radio station!

##wat
Streamit gets the hottest soundcloud tracks from reddit and then streams it over a IceCast radio stream!  
It will refresh every 20 minutes, queueing newly posted tracks.  
Streamit offers a API and a websocket integration (through pubnub).

###Features
- Multiple subreddit configuration
- REST API (optional)  
Allows you to see currently playing track, next track, and song queue. CORS enabled by default.
- [socket.io](http://socket.io) integration. (optional)  
Send a update to your frontend whenever the current song changes!  
- Works with HTML5 audio tag in all new major browsers.  
- Doesn't download anything, pipes mp3 data straight to the icecast server.  
No harddisk space/high amounts of RAM needed.
- Reddit listing can be configured to your likings. Rather hear the newest tracks only? Posted today? No problem.

###Requirements
- A (running) IceCast server.  
Might work with shoutcast but not tested.

###Setup
0. `npm install streamit -g`
1. Find streamit installation directory (`which streamit`) & cd into it.
2. Edit the config.json file to your likings.
2. If you're not making use of pubnub, change api.pubnub to false.
If you are, don't forget to enter both the publish and the subscribe key.
3. Idem dito for the API (api.enabled)
4. `streamit` baby!
5. Connect to your radio stream and enjoy! (probably http://127.0.0.1:8000/streamit)

###Demo  
There's currently a live server running on https://trapped.io/ making use of both the API and websocket capabilities.  
<img src="https://i.imgur.com/RuUlpO4.png">
