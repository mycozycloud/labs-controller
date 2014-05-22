module.exports = (app, server, callback) ->
    utils = require './middlewares/utils'
    utils.initToken callback
