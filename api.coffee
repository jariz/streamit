restify = require 'restify'
config = require './config.json'
log = require('./log')()
io = require('socket.io')

module.exports =
  class Api
    server: undefined
    scheduler: undefined
    io: undefined

    constructor: (@scheduler) ->
      @server = restify.createServer
        name: 'redditradio'
        version: '0.1.0'

      @server.use restify.acceptParser(@server.acceptable)
      @server.use restify.queryParser()
      @server.use restify.bodyParser()
      @server.use restify.CORS()
      @io = io.listen @server.server

      @server.get "/", => @home.apply @, arguments
      @server.get "/current", => @current.apply @, arguments

    start: ->
      @server.listen config.api.port
      log.log "info", "API online at http://127.0.0.1:" + config.api.port + "/" #todo hardcoded, ew.

      if config.api.websocket
        @scheduler.on "newtrack", (track) =>
          @io.emit 'track',
            "title": track.title
            "artist": track.artist
            "link": track.scUrl
            "comments": track.redditUrl
            "metadata": track.metadata


    home: (req, res, next) ->
      res.send
        "connected": "http://" + config.radio.host + ":" + config.radio.port + config.radio.mount
        "uptime": +new Date(+new Date() - @scheduler.started)
        #debug stuff, probably remove lat0r
        "queue": @scheduler.queue
        "queuePosition": @scheduler.queuePos
      next()

    current: (req, res, next) ->
      res.send
        "title": @scheduler.track.title
        "artist": @scheduler.track.artist
        "link": @scheduler.track.scUrl
        "comments": @scheduler.track.redditUrl
        "metadata": @scheduler.track.metadata
      next()