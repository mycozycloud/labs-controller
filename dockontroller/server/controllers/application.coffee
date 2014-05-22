DockerCommander = require '../lib/controller'
utils = require '../middlewares/utils'

commander = new DockerCommander()

module.exports.start = (req, res, next) ->
    # TODO : realtime docker to restart docker if necessary
    app = req.body.start
    name = app.name
    if name is 'data-system'
        if commander.exist(name)
            commander.startDataSystem (err) ->
                next err if err?
                res.send 200, app
        else
            commander.install "mycozycloud/#{name}", 'latest', {env: ['name':name, 'token':utils.getToken()]}, (err) =>
                next err if err?
                commander.startDataSystem name, (err) =>
                    next err if err?
                    res.send 200, app
    else if name is 'proxy'
        if commander.exist("proxy")
            commander.startProxy (err, app) ->
                next err if err?
                res.send 200, app
        else
            commander.installProxy (err) ->
                next err if err?
                commander.startProxy (err, app) ->
                    next err if err?
                    res.send 200, app
    else
        if commander.exist(name)
            commander.startApplication name, (err, image, port) =>
                next err if err?
                app.port = port
                res.send 200, app
        else
            if name is 'home'
                app.password = utils.getToken()
            commander.install "mycozycloud/#{name}", 'latest', {env: ['name':name, 'token':app.password]}, (err) =>
                next err if err?
                commander.startApplication name, (err) =>
                    next err if err?
                    res.send 200, app


module.exports.stop = (req, res, next) ->
    app = req.body.stop
    commander.stop app.name, (err, image) ->
        next err if err?
        res.send 200, {}


module.exports.clean = (req, res, next) ->
    name = req.body
    commander.uninstall name, (err) ->
        next err if err?
        res.send 200, {}


