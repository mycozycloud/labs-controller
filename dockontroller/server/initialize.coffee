module.exports = (app, server, callback) ->
    utils = require './middlewares/utils'
    utils.initToken callback


DockerCommander = require '../server/lib/controller'
commander = new DockerCommander()

log = console.log.bind console


commander.install 'mycozycloud/couchdb', 'latest', {}, (err) ->
    # console.log arguments
    return log err if err


    commander.install 'mycozycloud/datasystem', 'latest', {}, (err) ->
        # console.log arguments
        return log err if err

        commander.startCouch (err) ->
            # console.log arguments
            return log err if err

            commander.startDataSystem (err) ->
                # console.log arguments
                return log err if err

                commander.install 'mycozycloud/home', 'latest', {}, (err, home) ->
                    return log err if err

                    commander.ambassador 'proxy', 9104, (err) ->
                        return log err if err

                        commander.ambassador 'controller', 9002, (err) ->
                            return log err if err

                            commander.startHome (err, data, homePort) ->
                                return log err if err

                                console.log "HOME PORT", homePort

                                commander.startProxy homePort, (err) ->
                                    return log err if err

                                    console.log "DONE"