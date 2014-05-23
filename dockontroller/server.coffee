americano = require 'americano'
initialize = require './server/initialize'

port = process.env.PORT || 9002
americano.start name: 'cozy-controller', port: port, (app, server) ->
    initialize app, server, () =>
        app.server = server
    
