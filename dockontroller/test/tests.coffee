
DockerCommander = require '../server/lib/controller'

commander = new DockerCommander()


commander.installApplication 'mycozycloud/couchdb', 'latest', {}, (err) ->
    console.log arguments
    return if err

    commander.installApplication 'mycozycloud/datasystem', 'latest', {}, (err) ->
        console.log arguments
        return if err

        commander.startCouch (err) ->
            console.log arguments
            return if err

            commander.startDataSystem (err) ->
                console.log arguments
                return if err

                myapp = 'aenario/labs-controller-nodejsapp'
                commander.installApplication myapp, 'latest', {}, (err) ->
                    console.log arguments
                    return if err

                    commander.startApplication 'labs-controller-nodejsapp', (err) ->
                        console.log arguments
                        console.log 'DONE'