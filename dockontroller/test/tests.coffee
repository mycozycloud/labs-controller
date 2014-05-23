
DockerCommander = require '../server/lib/controller'

commander = new DockerCommander()


http = require 'http'

log = console.log.bind console

commander.running()

# commander.install 'mycozycloud/couchdb', 'latest', {}, (err) ->
#     # console.log arguments
#     return log err if err


#     commander.install 'mycozycloud/datasystem', 'latest', {}, (err) ->
#         # console.log arguments
#         return log err if err

#         commander.startCouch (err) ->
#             # console.log arguments
#             return log err if err

#             commander.startDataSystem (err) ->
#                 # console.log arguments
#                 return log err if err

#                 commander.install 'mycozycloud/home', 'latest', {}, (err, home) ->
#                     return log err if err

#                     commander.ambassador 'proxy', 9104, (err) ->
#                         return log err if err

#                         commander.startHome (err, data, homePort) ->
#                             return log err if err

#                             console.log "HOME PORT", homePort

#                             commander.startProxy homePort, (err) ->
#                                 return log err if err

#                                 console.log "DONE"



#                 # myapp = 'aenario/labs-controller-nodejsapp'
#                 # commander.install myapp, 'latest', {}, (err) ->
#                 #     console.log arguments
#                 #     return log err if err

#                 #     commander.startApplication 'labs-controller-nodejsapp', (err) ->
#                 #         console.log arguments
#                 #         console.log 'DONE'
