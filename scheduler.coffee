Reddit = require './reddit'
every = require('schedule').every
log = require('./log')()
Track = require './track'
async = require 'async'

module.exports =
  class Scheduler

    # array with soundcloud links pulled from reddit
    queue: []
    # current position in queue
    queuePos: 0

    icecast: undefined

    start: (cb) ->
      log.log "info", "Scheduler is initializing..."
      every('20m').do => @refresh false
      @refresh false, cb

    process: (@icecast) ->
      async.whilst (=> @queuePos < @queue.length)
      , ((cb) =>
          link = @queue[@queuePos]
          track = new Track link
          track.resolve (err) =>
            if err
              log.log "warn", "Unable to resolve url", link, "Skipping!"
              @queuePos++
              return cb()

            track.stream @icecast, =>
              @queuePos++
              cb() #play next

      ), (=>
          log.log "warn", "Woops, appears we've gone through the queue."
          log.log "warn", "Getting new links and restarting..."
          @refresh true, => @process()
      )

    refresh: (clearOld, cb) ->
      # refresh queue, checking if new sc links are available.
      # if clearOld is true, remove previous queue
      Reddit.getLinks (err, links) =>
        cb err if err and cb
        if not clearOld then @queue = @queue.concat links
        else @queue = links
        cb null if cb
