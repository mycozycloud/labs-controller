DockerCommander = require '../lib/controller'
utils = require '../middlewares/utils'

commander = new DockerCommander()

install = (name, app, cb) ->
    if not commander.exist(name)
        if name in ['home', 'proxy', 'datasystem']
            app.password = utils.getToken()
        commander.installApplication "mycozycloud/#{name}", name, {env:['name':name, 'token':app.password]}, (err) =>
            cb (err)
    else 
        cb()


module.exports.start = (req, res, next) ->
    # TODO : realtime docker to restart docker if necessary
    app = req.body.start
    name = app.name
    install name, app, (err) =>
        next err if err?
        switch name
            when 'data-system'
                commander.startDataSystem (err) ->
                    next err if err?
                    res.send 200, app
            when 'couchdb'
                commander.startCouch (err) ->
                    next err if err?
                    res.send 200, app
            when 'proxy'
                commander.startProxy (err, app) ->
                    next err if err?
                    res.send 200, app
            else
                commander.startApplication name, (err, image, port) =>
                    next err if err?
                    app.port = port
                    res.send 200, app


module.exports.stop = (req, res, next) ->
    app = req.body.stop
    if commander.exist(app.name)
        commander.stop app.name, (err, image) ->
            next err if err?
            res.send 200, {}
    else
        res.send 404, {}


module.exports.clean = (req, res, next) ->
    app = req.body
    if commander.exist(app.name)
        commander.uninstallApplication app.name, (err) ->
            next err if err?
            res.send 200, {}
    else
        res.send 404, {}



