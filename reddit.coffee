config = require './config.json'
request = require 'request-promise'
log = require('./log')()

module.exports =
  class Reddit
    @getLinks: (cb) ->
      subs = ""
      config.reddit.subreddits.forEach (sub) ->
        subs += sub + "+"
      subs = subs.substring 0, subs.length - 1

      uri = "https://www.reddit.com/r/" + subs + "/search.json?q=site%3Asoundcloud.com&sort=" + config.reddit.sort + "&restrict_sr=on"+ "&limit=" + config.reddit.amount
      if config.reddit.period then uri += "&t=" + config.reddit.period

      request
        uri: uri
        json: true
        headers:
          'User-Agent': 'Streamit 0.1 by Jari Zwarts. https://github.com/jariz/streamit'
      .then (resp) ->
        links = []
        resp.data.children.forEach (child) ->
          if config.reddit.onlyPositive and child.data.score < 1 then return
          links.push child.data
        log.log "info", "[reddit] got", links.length, "links"
        cb null, links
      .catch (err) ->
        cb err