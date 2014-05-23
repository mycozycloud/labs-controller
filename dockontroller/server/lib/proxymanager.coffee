forever = require 'forever-monitor'

PROXYPATH = '../cozy-proxy/build/server.js'

module.exports = class ProxyManager

    start: (env, callback) ->
        @proxy_process.stop() if @proxy_process

        @proxy_process = new forever.Monitor PROXYPATH,
            max: 3, # @TODO
            silent: true,
            logFile: '/var/log/cozy_proxy.log'
            outFile: '/var/log/cozy_proxy_out.log'
            errFile: '/var/log/cozy_proxy_err.log'
            env: env

        @proxy_process.on 'start', ->
            callback null
            callback = null # avoid double call

        @proxy_process.on 'exit', ->
            if callback then callback new Error "PROXY CANT START"
            else
                console.log "PROXY HAS FAILLED TOO MUCH"
                setTimeout (=> process.exit 1), 1

        @proxy_process.on 'error', (err) ->
            console.log err

        @proxy_process.start()

    stop: ->
        @proxy_process.stop()
        @proxy_process = null