americano = require 'americano'
initialize = require './server/initialize'

port = process.env.PORT || 9002
host = process.env.HOST || '172.17.42.1'
americano.start name: 'cozy-controller', port: port, host: host, (app, server) ->
    initialize app, server, () =>
        app.server = server

