icecast = require 'icecast-source'
log = require('./log')()
Scheduler = require './scheduler'
Api = require './api'

module.exports =
  class Radio
    config: {}
    icecast: undefined
    constructor: ->
      @config = require "./config.json"

      scheduler = new Scheduler @icecast
      scheduler.start (err) =>
        if err
          log.log "error", "Scheduler init failed, nothing to play, quitting!", err
          return process.exit 1

        @icecast = new icecast
          port: @config.radio.port
          password: @config.radio.pass
          mount: @config.radio.mount
        , (err) =>
            if err
              log.log "error", "Unable to connect to IceCast source.", err
              return

            log.log "info", "Connected to " + @config.radio.host + ":" + @config.radio.port + " successfully!"

            # start API
            api = new Api scheduler
            api.start()

            # let scheduler process it's loaded queue
            scheduler.process @icecast