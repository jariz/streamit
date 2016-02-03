icecast = require 'icecast-source'
log = require('./log')()
Scheduler = require './scheduler'
Api = require './api'

module.exports =
  class Radio
    icecast: undefined
    constructor: ->
      config = require "./config.json"

      scheduler = new Scheduler @icecast
      scheduler.start (err) =>
        if err
          log.log "error", "Scheduler init failed, nothing to play, quitting!", err
          return process.exit 1

        @icecast = new icecast
          port: config.radio.port
          password: config.radio.pass
          mount: config.radio.mount
        , (err) =>
            if err
              log.log "error", "Unable to connect to IceCast source.", err
              return

            @icecast.on "end", =>
              log.error "error", "FATAL: Disconnected from source!"
              process.exit 2

            log.log "info", "Connected to " + config.radio.host + ":" + config.radio.port + " successfully!"

            # start API
            if config.radio
              api = new Api scheduler
              api.start()

            # let scheduler process it's loaded queue
            scheduler.process @icecast