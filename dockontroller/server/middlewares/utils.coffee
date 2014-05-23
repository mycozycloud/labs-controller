fs = require 'fs'
token = ""

module.exports.initToken = (cb) =>
    if fs.existsSync '/etc/cozy/controller.token'
        fs.readFile '/etc/cozy/controller.token', 'utf8', (err, data) ->
            if not err?
                token = data.split('\n')[0]
            cb()
    else
        console.log "Option auth cannot work : file '/etc/cozy/controller.token doesn't exist"
        cb()


# Get the permission from the request's params
module.exports.checkToken = (req, res, next) =>
    return next() if process.env.NODE_ENV not in ['production', 'test']
    if req.headers?['x-auth-token']?  and req.headers['x-auth-token'] is token
        next()
    else
        err = new Error 'not authorized'
        err.status = 401
        next err

module.exports.getToken = () =>
    return token