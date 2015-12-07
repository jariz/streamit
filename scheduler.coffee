Reddit = require './reddit'
every = require('schedule').every
log = require('./log')()
Track = require './track'
async = require 'async'

module.exports =
  class Scheduler extends require('events').EventEmitter

    # array with soundcloud links pulled from reddit
    queue: []
    # current position in queue
    queuePos: 0

    # Current track
    track: undefined

    icecast: undefined

    started: undefined

    start: (cb) ->
      @started = +new Date()
      log.log "info", "Scheduler is initializing..."
      every('10s').do => @refresh false
      @refresh false, cb

    process: (@icecast) ->
      async.whilst (=> @queuePos < @queue.length)
      , ((cb) =>
          link = @queue[@queuePos]
          @track = new Track link
          @track.resolve (err) =>
            if err
              log.log "warn", "Unable to resolve url", link, "Skipping!"
              @queuePos++
              return cb()

            @emit "newtrack", @track
            @track.stream @icecast, =>
              @queuePos++
              cb() #play next

      ), (=>
          @emit "restart"
          log.log "warn", "Woops, appears we've gone through the queue."
          log.log "warn", "Getting new links and restarting..."
          @refresh true, => @process()
      )

    refresh: (clearOld, cb) ->
      # refresh queue, checking if new sc links are available.
      # if clearOld is true, remove previous queue
      Reddit.getLinks (err, links) =>
        cb err if err and cb
        if not clearOld
          #grab everything that isn't already in the queue & push it to the end
          newlinks = links.filter (item) => @queue.indexOf item isnt -1
          if newlinks.length > 0 then log.log "Queued", newlinks.length, "new links"
          @queue.push link for link in newlinks
        else @queue = links
        cb null if cb
