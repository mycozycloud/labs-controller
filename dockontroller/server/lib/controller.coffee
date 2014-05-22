Docker = require 'dockerode'
logrotate = require 'logrotate-stream'

module.exports = class DockerCommander

    # docker connection options
    socketPath: process.env.DOCKERSOCK or '/var/run/docker.sock'
    version: 'v1.10'

    constructor: ->
        @docker = new Docker {@socketPath, @version}


    # useful params
    # Volumes
    #
    installApplication: (imagename, version, params, callback) ->

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
                # 'Hostname': '',
                # 'User': '',
                # 'AttachStdin': false,
                # 'AttachStdout': true,
                # 'AttachStderr': true,
                # 'OpenStdin': false,
                # 'StdinOnce': false,
                'Env': params.env,
                # 'Cmd': [],
                # 'Volumes': {},
                # 'VolumesFrom': ''

            # create a container
            @docker.createContainer options, callback


    uninstallApplication: (slug, callback) ->

        @stop slug, (err, image) ->
            return callback err if err

            container.remove callback


    # useful params
    # Links
    #
    start: (slug, params, callback) ->
        container = @docker.getContainer slug
        logfile = "/var/log/cozy_#{slug}.log"
        logStream = logrotate file: logfile, size: '100k', keep: 3

        # @TODO, do the piping in child process ?
        singlepipe = stream: true, stdout: true, stderr: true
        container.attach singlepipe, (err, stream) ->
            return callback err if err

            stream.setEncoding 'utf8'
            stream.pipe logStream, end: true

            startOptions =
                'Links': params.Links or []

            container.start startOptions, callback


    stop: (slug) ->
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
        @start 'datasystem', Links: ['couchdb:couch'], callback

    startApplication: (slug, callback) ->
        @start slug, Links: ['datasystem:datasystem'], callback


    exist: (slug) ->
        return true