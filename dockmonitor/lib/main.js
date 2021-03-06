// Generated by CoffeeScript 1.7.1
(function() {
  var Client, ControllerClient, appsPath, async, axon, client, controllerUrl, couchUrl, dataSystemUrl, exec, fs, getAuthCouchdb, getToken, handleError, homeClient, homeUrl, indexerUrl, manifest, pkg, program, proxyUrl, spawn, statusClient, token, version;

  require("colors");

  program = require('commander');

  async = require("async");

  fs = require("fs");

  exec = require('child_process').exec;

  spawn = require('child_process').spawn;

  Client = require("request-json").JsonClient;

  ControllerClient = require("cozy-clients").ControllerClient;

  axon = require('axon');

  pkg = require('../package.json');

  version = pkg.version;

  couchUrl = "http://localhost:5984/";

  dataSystemUrl = "http://localhost:9101/";

  indexerUrl = "http://localhost:9102/";

  controllerUrl = "http://localhost:9002/";

  homeUrl = "http://localhost:9103/";

  proxyUrl = "http://localhost:9104/";

  homeClient = new Client(homeUrl);

  statusClient = new Client('');

  appsPath = '/usr/local/cozy/apps';

  getToken = function() {
    var err, token;
    if (fs.existsSync('/etc/cozy/controller.token')) {
      try {
        token = fs.readFileSync('/etc/cozy/controller.token', 'utf8');
        token = token.split('\n')[0];
        return token;
      } catch (_error) {
        err = _error;
        console.log("Are you sure, you are root ?");
        return null;
      }
    } else {
      return null;
    }
  };

  getAuthCouchdb = function(callback) {
    return fs.readFile('/etc/cozy/couchdb.login', 'utf8', (function(_this) {
      return function(err, data) {
        var password, username;
        if (err) {
          console.log("Cannot read login in /etc/cozy/couchdb.login");
          return callback(err);
        } else {
          username = data.split('\n')[0];
          password = data.split('\n')[1];
          return callback(null, username, password);
        }
      };
    })(this));
  };

  handleError = function(err, body, msg) {
    var _ref;
    if (err) {
      console.log(err);
    }
    console.log(msg);
    if (body != null) {
      if (body.msg != null) {
        console.log(body.msg);
      } else if (((_ref = body.error) != null ? _ref.message : void 0) != null) {
        console.log("An error occured.");
        console.log(body.error.message);
        console.log(body.error.result);
        console.log(body.error.code);
        console.log(body.error.blame);
      } else {
        console.log(body);
      }
    }
    return process.exit(1);
  };

  token = getToken();

  client = new ControllerClient({
    token: token
  });

  manifest = {
    "domain": "localhost",
    "repository": {
      "type": "git"
    },
    "scripts": {
      "start": "server.coffee"
    }
  };

  program.version(version).usage('<action> <app>');

  program.command("install <app> <homeport> ").description("Install application").option('-r, --repo <repo>', 'Use specific repo').option('-d, --displayName <displayName>', 'Display specific name').action(function(app, homeport, options) {
    var path;
    manifest.name = app;
    if (options.displayName != null) {
      manifest.displayName = options.displayName;
    } else {
      manifest.displayName = app;
    }
    manifest.user = app;
    console.log("Install started for " + app + "...");
    if (app === 'datasystem' || app === 'home' || app === 'proxy' || app === 'couchdb') {
      if (options.repo == null) {
        manifest.repository.url = "https://github.com/mycozycloud/cozy-" + app + ".git";
      } else {
        manifest.repository.url = options.repo;
      }
      return client.clean(manifest, function(err, res, body) {
        return client.start(manifest, function(err, res, body) {
          if (err || (body.error != null)) {
            return handleError(err, body, "Install failed");
          } else {
            return client.brunch(manifest, (function(_this) {
              return function() {
                return console.log("" + app + " successfully installed");
              };
            })(this));
          }
        });
      });
    } else {
      if (options.repo == null) {
        manifest.git = "https://github.com/mycozycloud/cozy-" + app + ".git";
      } else {
        manifest.git = options.repo;
      }
      path = "api/applications/install";
      homeClient = new Client("http://localhost:" + homeport + "/");
      return homeClient.post(path, manifest, function(err, res, body) {
        if (err || body.error) {
          return handleError(err, body, "Install home failed");
        } else {
          return waitInstallComplete(body.app.slug, function(err, appresult) {
            if ((err == null) && appresult.state === "installed") {
              return console.log("" + app + " successfully installed");
            } else {
              return handleError(null, null, "Install home failed");
            }
          });
        }
      });
    }
  });

  program.command("install-cozy-stack").description("Install cozy via the Cozy Controller").action(function() {
    var installApp;
    installApp = function(name, callback) {
      manifest.repository.url = "https://github.com/mycozycloud/cozy-" + name + ".git";
      manifest.name = name;
      manifest.user = name;
      console.log("Install started for " + name + "...");
      return client.clean(manifest, function(err, res, body) {
        return client.start(manifest, function(err, res, body) {
          if (err || (body.error != null)) {
            return handleError(err, body, "Install failed");
          } else {
            return client.brunch(manifest, (function(_this) {
              return function() {
                console.log("" + name + " successfully installed");
                return callback(null);
              };
            })(this));
          }
        });
      });
    };
    return installApp('couchdb', (function(_this) {
      return function() {
        return installApp('datasystem', function() {
          return installApp('home', function() {
            return installApp('proxy', function() {
              return console.log('Cozy stack successfully installed');
            });
          });
        });
      };
    })(this));
  });

  program.command("uninstall <app>").description("Remove application").action(function(app) {
    var path;
    console.log("Uninstall started for " + app + "...");
    if (app === 'datasystem' || app === 'home' || app === 'proxy' || app === 'couchdb') {
      manifest.name = app;
      manifest.user = app;
      return client.clean(manifest, function(err, res, body) {
        if (err || (body.error != null)) {
          return handleError(err, body, "Uninstall failed");
        } else {
          return console.log("" + app + " successfully uninstalled");
        }
      });
    } else {
      path = "api/applications/" + app + "/uninstall";
      return homeClient.del(path, function(err, res, body) {
        if (err || res.statusCode !== 200) {
          return handleError(err, body, "Uninstall home failed");
        } else {
          return console.log("" + app + " successfully uninstalled");
        }
      });
    }
  });

  program.command("uninstall-all").description("Uninstall all apps from controller").action(function(app) {
    console.log("Uninstall all apps...");
    return client.cleanAll(function(err, res, body) {
      if (err || (body.error != null)) {
        return handleError(err, body, "Uninstall all failed");
      } else {
        return console.log("All apps successfully uinstalled");
      }
    });
  });

  program.command("start <app>").description("Start application").action(function(app) {
    var find;
    console.log("Starting " + app + "...");
    if (app === 'datasystem' || app === 'home' || app === 'proxy' || app === 'couchdb') {
      manifest.name = app;
      manifest.repository.url = "https://github.com/mycozycloud/cozy-" + app + ".git";
      manifest.user = app;
      return client.stop(app, function(err, res, body) {
        return client.start(manifest, function(err, res, body) {
          if (err || (body.error != null)) {
            return handleError(err, body, "Start failed");
          } else {
            return console.log("" + app + " successfully started");
          }
        });
      });
    } else {
      find = false;
      homeClient.host = homeUrl;
      return homeClient.get("api/applications/", function(err, res, apps) {
        var path, _i, _len, _ref;
        if ((apps != null) && (apps.rows != null)) {
          _ref = apps.rows;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            manifest = _ref[_i];
            if (manifest.name === app) {
              find = true;
              path = "api/applications/" + manifest.slug + "/start";
              homeClient.post(path, manifest, function(err, res, body) {
                if (err || body.error) {
                  return handleError(err, body, "Start failed");
                } else {
                  return console.log("" + app + " successfully started");
                }
              });
            }
          }
          if (!find) {
            return console.log("Start failed : application " + app + " not found");
          }
        } else {
          return console.log("Start failed : no applications installed");
        }
      });
    }
  });

  program.command("stop <app>").description("Stop application").action(function(app) {
    var find;
    console.log("Stopping " + app + "...");
    if (app === 'datasystem' || app === 'home' || app === 'proxy' || app === 'couchdb') {
      manifest.name = app;
      manifest.user = app;
      return client.stop(app, function(err, res, body) {
        if (err || (body.error != null)) {
          return handleError(err, body, "Stop failed");
        } else {
          return console.log("" + app + " successfully stopped");
        }
      });
    } else {
      find = false;
      homeClient.host = homeUrl;
      return homeClient.get("api/applications/", function(err, res, apps) {
        var path, _i, _len, _ref;
        if ((apps != null) && (apps.rows != null)) {
          _ref = apps.rows;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            manifest = _ref[_i];
            if (manifest.name === app) {
              find = true;
              path = "api/applications/" + manifest.slug + "/stop";
              homeClient.post(path, manifest, function(err, res, body) {
                if (err || body.error) {
                  return handleError(err, body, "Start failed");
                } else {
                  return console.log("" + app + " successfully stopperd");
                }
              });
            }
          }
          if (!find) {
            return console.log("Stop failed : application " + manifest.name + " not found");
          }
        } else {
          return console.log("Stop failed : no applications installed");
        }
      });
    }
  });

  program.command("restart <app>").description("Restart application").action(function(app) {
    console.log("Stopping " + app + "...");
    if (app === 'datasystem' || app === 'home' || app === 'proxy' || app === 'couchdb') {
      return client.stop(app, function(err, res, body) {
        if (err || (body.error != null)) {
          return handleError(err, body, "Stop failed");
        } else {
          console.log("" + app + " successfully stopped");
          console.log("Starting " + app + "...");
          manifest.name = app;
          manifest.repository.url = "https://github.com/mycozycloud/cozy-" + app + ".git";
          manifest.user = app;
          return client.start(manifest, function(err, res, body) {
            if (err) {
              return handleError(err, body, "Start failed");
            } else {
              return console.log("" + app + " sucessfully started");
            }
          });
        }
      });
    } else {
      return homeClient.post("api/applications/" + app + "/stop", {}, function(err, res, body) {
        var path;
        if (err || (body.error != null)) {
          return handleError(err, body, "Stop failed");
        } else {
          console.log("" + app + " successfully stopped");
          console.log("Starting " + app + "...");
          path = "api/applications/" + app + "/start";
          return homeClient.post(path, {}, function(err, res, body) {
            if (err) {
              return handleError(err, body, "Start failed");
            } else {
              return console.log("" + app + " sucessfully started");
            }
          });
        }
      });
    }
  });

  program.command("restart-cozy-stack").description("Restart cozy trough controller").action(function() {
    var restartApp;
    restartApp = function(name, callback) {
      manifest.repository.url = "https://github.com/mycozycloud/cozy-" + name + ".git";
      manifest.name = name;
      manifest.user = name;
      console.log("Restart started for " + name + "...");
      return client.stop(manifest, function(err, res, body) {
        return client.start(manifest, function(err, res, body) {
          if (err || (body.error != null)) {
            return handleError(err, body, "Start failed");
          } else {
            return client.brunch(manifest, (function(_this) {
              return function() {
                console.log("" + name + " successfully started");
                return callback(null);
              };
            })(this));
          }
        });
      });
    };
    return restartApp('couchdb', (function(_this) {
      return function() {
        return restartApp('datasystem', function() {
          return restartApp('home', function() {
            return restartApp('proxy', function() {
              return console.log('Cozy stack successfully restarted');
            });
          });
        });
      };
    })(this));
  });

  program.command("*").description("Display error message for an unknown command.").action(function() {
    return console.log('Unknown command, run "dockmonitor --help"' + ' to know the list of available commands.');
  });

  program.parse(process.argv);

}).call(this);
