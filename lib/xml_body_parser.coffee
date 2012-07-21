utils = require('express').utils
xml2js = require 'xml2js'
parser = new xml2js.Parser()

module.exports = ->
  return (req, res, next) ->
    return next() if req._body
    req.body ||= {}

    # Ignore GET and HEAD methods
    return next() if req.method is 'GET' or req.method is 'HEAD'

    # Verify the MIME type
    return next() unless req.is('text/xml') or req.is('application/xml')

    # Marked the body as parsed
    req._body = true

    # Do the parsing
    buf = ''
    req.setEncoding('utf8')
    req.on 'data', (chunk) -> buf += chunk
    req.on 'end', ->
      parser.parseString buf, (err, json) ->
        if err
          err.status = 400
          next err
        else
          req.body = json
          next()
