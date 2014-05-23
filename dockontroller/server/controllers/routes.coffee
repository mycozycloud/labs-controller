# See documentation on https://github.com/frankrousseau/americano#routes

application = require './application'
utils = require '../middlewares/utils'


module.exports =

    '/':
        get: (req, res) -> res.send 'THIS IS THE CONTROLLER'

    'drones/running':
        get: [
            utils.checkToken
            application.running
        ]

    'drones/:id/start':
        post: [
            utils.checkToken
            application.start
        ]

    'drones/:id/stop':
        post: [
            utils.checkToken
            application.stop
        ]

    'drones/:id/clean':
        post: [
            utils.checkToken
            application.clean
        ]