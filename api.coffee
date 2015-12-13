restify = require 'restify'
config = require './config.json'
log = require('./log')()
pubnub = require 'pubnub'

module.exports =
  class Api
    server: undefined
    scheduler: undefined
    pubnub: undefined

    constructor: (@scheduler) ->
      @server = restify.createServer
        name: 'redditradio'
        version: '0.1.0'

      @server.use restify.acceptParser(@server.acceptable)
      @server.use restify.queryParser()
      @server.use restify.bodyParser()
      @server.use restify.CORS()

      @server.get "/", => @home.apply @, arguments
      @server.get "/current", => @current.apply @, arguments

    start: ->
      @server.listen config.api.port
      log.log "info", "API online at http://127.0.0.1:" + config.api.port + "/" #todo hardcoded, ew.

      if config.api.pubnub
        @pubnub = new pubnub
          ssl: true
          publish_key: config.api.publish_key
          subscribe_key: config.api.subscribe_key

        @scheduler.on "newtrack", (track) =>
          @pubnub.publish
            channel: 'tracks'
            message:
              "title": track.title
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
        "link": @scheduler.track.scUrl
        "comments": @scheduler.track.redditUrl
        "metadata": @scheduler.track.metadata
      next()