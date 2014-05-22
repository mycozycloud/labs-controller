
DockerCommander = require './src/controller'

commander = new DockerCommander()


http = require 'http'

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

                console.log require('os').networkInterfaces()

                fakeProxy = http.createServer (request, response) ->
                  console.log "WE GOT HIT !"
                  response.writeHead 200, "Content-Type": "application/json"
                  response.end "Hello World\n"
                fakeProxy.listen 9104, commander.getContainerVisibleIp()
                console.log "fakeProxy listening"

                commander.ambassador 'proxy', 9104, (err) ->
                    return log err if err

                    commander.install 'mycozycloud/home', 'latest', {}, (err, home) ->
                        return log err if err

                        commander.startHome (err) ->
                            console.log 'DONE'


                # myapp = 'aenario/labs-controller-nodejsapp'
                # commander.install myapp, 'latest', {}, (err) ->
                #     console.log arguments
                #     return log err if err

                #     commander.startApplication 'labs-controller-nodejsapp', (err) ->
                #         console.log arguments
                #         console.log 'DONE'