request = require "request-promise"
clientid = "23aca29c4185d222f2e536f440e96b91"
log = require("./log")()
parser = require "streammachine/src/streammachine/parsers/mp3"
FrameChunker = require("streammachine/src/streammachine/sources/base").FrameChunker
Progress = require 'progress'

module.exports =
  class Track extends require("events").EventEmitter
    mp3Url: undefined
    scUrl: undefined
    mp3Stream: undefined
    title: ""
    track: undefined

    constructor: (@scUrl) ->
      @parser = new parser()
      @emitDuration = 0.2 * 1000

    resolve: (cb) ->
      #get MP3 url from soundcloud.
      request
        uri: "https://api.soundcloud.com/resolve?url=" + @scUrl + "&client_id=" + clientid
        json: true
      .then (track) =>
        @track = track
        if not @track.stream_url then return cb new Error('Invalid soundcloud track url')

        dashIndex = @track.title.indexOf "-"
        if dashIndex isnt -1
          @title = @track.title
        else
          @title = @track.user.username + " - " + @track.title

        stream_url = @track.stream_url + "?client_id=" + clientid
        log.log "info", "Playing", @title
        request
          uri: stream_url
          followRedirect: false
          resolveWithFullResponse: true
          simple: false
        .then (response) =>
          @mp3Url = response.headers.location
          cb()
        .catch (err) =>
          log.log "error", "Unable to resolve soundcloud stream url"
          cb err
      .catch (err) ->
        log.log "error", "Unable to resolve soundcloud url"
        cb err

    stream: (output, cb) ->
      #open mp3 url as stream, run parser, run chunker, pipe to icecast
      @chunker = new FrameChunker @emitDuration
      chunks = []

      @chunker.on "readable", =>
        while c = @chunker.read()
          chunks.push c

      #write the actual chunks to the stream!
      progress = undefined
      chunkIndex = 0
      interval =
        setInterval =>
          if chunks.length is 0 then return
          if chunkIndex is chunks.length
            clearInterval interval
            progress.terminate()
            cb null
            return

          progress = new Progress ' [:bar] :percent', total: 100 if not progress
          progress.update chunkIndex / chunks.length
          chunk = chunks[chunkIndex]
          output.write chunk.data
          chunkIndex++
        , @emitDuration

      @parser.on "frame", (frame,header) =>
        @chunker.write
          frame: frame
          header: header

      request(@mp3Url).pipe @parser