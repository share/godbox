# This is a little prototype browserchannel wrapper for the session code.
fs = require 'fs'
{Duplex} = require 'stream'
browserChannel = require('browserchannel').server
express = require 'express'
argv = require('optimist').argv
livedb = require 'livedb'
livedbMongo = require 'livedb-mongo'
redis = require 'redis'
sharejs = require 'share'

app = express()

app.use express.static "#{__dirname}/public"
app.use express.static "#{__dirname}/node_modules/share/webclient"

# Redis defaulting to database 1. Set using -r 0 or something.
redisClient = redis.createClient()
redisClient.select (argv.r or 1)

shares = {}

getShare = (dbName) ->
  console.log dbName
  if !shares[dbName]
    backend = livedb.client livedbMongo("localhost:27017/#{dbName}?auto_reconnect", safe:false), redisClient, {}
    shares[dbName] = sharejs.server.createClient {backend}

  shares[dbName]


app.use browserChannel (client, req) ->
  stream = new Duplex objectMode:yes
  stream._write = (chunk, encoding, callback) ->
    console.log 's->c ', chunk
    if client.state isnt 'closed' # silently drop messages after the session is closed
      client.send chunk
    callback()

  stream._read = -> # Ignore. You can't control the information, man!

  stream.headers = client.headers
  stream.remoteAddress = stream.address

  share = null

  client.on 'message', (data) ->
    if share is null
      share = getShare data
      share.listen stream
      return

    console.log 'c->s ', data
    stream.push data

  stream.on 'error', (msg) ->
    client.stop()

  client.on 'close', (reason) ->
    stream.emit 'close'
    stream.emit 'end'
    stream.end()

  # ... and give the stream to ShareJS.

app.use app.router
app.get '/:db/:collection', (req, res, next) ->
  console.log req.path
  source = fs.readFileSync('public/index.html', 'utf8')
    .replace(/\$\$DB/g, req.params.db)
    .replace(/\$\$COLLECTION/g, req.params.collection)

  res.send source

port = argv.p or 7777
app.listen port
console.log "Listening on http://localhost:#{port}/"

