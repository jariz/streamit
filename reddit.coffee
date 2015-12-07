config = require './config.json'
request = require 'request-promise'
log = require('./log')()

module.exports =
  class Reddit
    @getLinks: (cb) ->
      subs = ""
      config.subreddits.forEach (sub) ->
        subs += sub + "+"
      subs = subs.substring 0, subs.length - 1

      request
        uri: "https://www.reddit.com/r/" + subs + "/search.json?q=site%3Asoundcloud.com&sort=" + config.sort + "&restrict_sr=on&t=" + config.period + "&limit=" + config.amount
        json: true
        headers:
          'User-Agent': 'RedditRadio 0.1 by Jari Zwarts. https://github.com/jariz/redditradio'
      .then (resp) ->
        links = []
        resp.data.children.forEach (child) ->
          links.push child.data.url
        log.log "info", "[reddit] got", links.length, "links"
        cb null, links
      .catch (err) ->
        cb err