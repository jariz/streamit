restify = require 'restify'
config = require './config.json'
log = require('./log')()

module.exports =
  class Api
    server: undefined
    scheduler: undefined

    constructor: (@scheduler) ->
      @server = restify.createServer
        name: 'redditradio'
        version: '0.1.0'

      @server.use restify.acceptParser(@server.acceptable)
      @server.use restify.queryParser()
      @server.use restify.bodyParser()

      @server.get "/", => @home.apply @, arguments
      @server.get "/current", => @current.apply @, arguments

    start: ->
      @server.listen config.api.port
      log.log "info", "API online at http://127.0.0.1:" + config.api.port + "/" #todo hardcoded, ew.

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
        "metadata": @scheduler.track.metadata
      next()