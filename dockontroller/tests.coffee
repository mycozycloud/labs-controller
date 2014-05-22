
DockerCommander = require './src/controller'

commander = new DockerCommander()


commander.install 'mycozycloud/couchdb', 'latest', {}, (err) ->
    # console.log arguments
    return if err

    commander.install 'mycozycloud/datasystem', 'latest', {}, (err) ->
        # console.log arguments
        return if err

        commander.startCouch (err) ->
            # console.log arguments
            return if err

            commander.startDataSystem (err) ->
                # console.log arguments
                return if err

                # myapp = 'aenario/labs-controller-nodejsapp'
                # commander.install myapp, 'latest', {}, (err) ->
                #     console.log arguments
                #     return if err

                #     commander.startApplication 'labs-controller-nodejsapp', (err) ->
                #         console.log arguments
                #         console.log 'DONE'

                commander.install 'mycozycloud/home', 'latest', {}, (err, home) ->
                    console.log home
                    return if err

                    commander.startApplication 'home', (err) ->
                        # console.log arguments
                        console.log 'DONE'