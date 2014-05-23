Docker = require 'dockerode'
ProxyManager = require './proxymanager'
logrotate = require 'logrotate-stream'
request = require 'request'

module.exports = class DockerCommander

    # docker connection options
    socketPath: process.env.DOCKERSOCK or '/var/run/docker.sock'
    version: 'v1.10'

    constructor: ->
        @docker = new Docker {@socketPath, @version}
        @proxy = new ProxyManager

    getContainerVisibleIp: ->
        addresses = require('os').networkInterfaces()['docker0']
        return ad.address for ad in addresses when ad.family is 'IPv4'

    waitListening: (url, timeout, callback) ->
        i = 0
        do ping = ->
            i += 500
            console.log "PING", url, i, '/', timeout
            return callback new Error('timeout') if i > timeout
            request.get url, (err, response, body) ->
                if err then setTimeout ping, 500
                else callback null

    # useful params
    # Volumes
    #
    install: (imagename, version, params, callback) ->
        console.log "INSTALLING", imagename

        options =
            fromImage: imagename,
            tag: version

        # pull the image
        @docker.createImage options, (err, data) =>
            return callback err if err

            slug = imagename.split('/')[-1..]
            options =
                'name': slug
                'Image': imagename
                'Tty': false

            options[key] = value for key, value of params

            # create a container
            @docker.createContainer options, callback


    uninstall: (slug, callback) ->

        @stop slug, (err, image) ->
            return callback err if err

            container.remove (err) ->

    # fire up an ambassador that allow container to speak to the host
    ambassador: (slug, port, callback) ->
        console.log "AMBASSADOR", slug, port

        ip = @getContainerVisibleIp()
        options =
            name: slug
            Image: 'aenario/ambassador'
            Env: "#{slug.toUpperCase()}_PORT_#{port}_TCP=tcp://#{ip}:#{port}"
            ExposedPorts: {}

        options.ExposedPorts["#{port}/tcp"] = {}

        @docker.createContainer options, (err) =>
            return callback err if err
            container = @docker.getContainer slug
            container.start {}, callback

    # useful params
    # Links
    #
    start: (slug, params, callback) ->
        console.log "STARTING", slug
        container = @docker.getContainer slug
        logfile = "/var/log/cozy_#{slug}.log"
        logStream = logrotate file: logfile, size: '100k', keep: 3

        # @TODO, do the piping in child process ?
        singlepipe = stream: true, stdout: true, stderr: true
        container.attach singlepipe, (err, stream) =>
            return callback err if err

            stream.setEncoding 'utf8'
            stream.pipe logStream, end: true

            startOptions = params

            container.start startOptions, (err) =>
                return callback err if err

                container.inspect (err, data) =>
                    return callback err if err

                    # we wait for the container to actually start (ie. listen)
                    pingHost = data.NetworkSettings.IPAddress
                    for key, val of data.NetworkSettings.Ports
                        pingPort = key.split('/')[0]
                        hostPort = val?[0].HostPort
                        break

                    pingUrl = "http://#{pingHost}:#{pingPort}/"
                    @waitListening pingUrl, 5000, (err) =>
                        callback err, data, hostPort




    stop: (slug, callback) ->
        container = @docker.getContainer slug
        container.inspect (err, data) ->
            return callback err if err
            image = data.Image

            unless data.State.Running
                return callback null, image

            container.stop (err) ->
                return callback err if err
                callback null, image


    startCouch: (callback) ->
        @start 'couchdb', {}, callback

    startDataSystem: (callback) ->
        @start 'datasystem', Links: ['couchdb:couch'], (err, data) =>
            return callback err if err
            @dataSystemHost = data.NetworkSettings.IPAddress
            @dataSystemPort = key.split('/')[0] for key, val of data.NetworkSettings.Ports
            console.log "DS STARTED", @dataSystemHost, @dataSystemPort
            callback null, data

    startHome: (callback) ->
        @start 'home',
            PublishAllPorts: true
            Links: ['datasystem:datasystem', 'proxy:proxy']
        , callback

    startProxy: (homePort, callback) ->
        ip = @getContainerVisibleIp()
        env =
            HOST: '0.0.0.0'
            DATASYSTEM_HOST: @dataSystemHost
            DATASYSTEM_PORT: @dataSystemPort
            DEFAULT_REDIRECT_PORT: homePort

        @proxy.start env, (err) =>
            return callback err if err
            @waitListening 'http://localhost:9104/', 10000, callback

    startApplication: (slug, callback) ->
        @start slug,
            PublishAllPorts: true
            Links: ['datasystem:datasystem']
        , callback