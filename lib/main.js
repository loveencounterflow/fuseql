(function() {
  var CND, add_writestream, alert, badge, debug, dump, echo, help, info, levelfs, levelup, log, njs_path, rpr, step, suspend, urge, warn, whisper;

  njs_path = require('path');

  CND = require('cnd');

  rpr = CND.rpr.bind(CND);

  badge = 'FUSEQL/main';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  urge = CND.get_logger('urge', badge);

  whisper = CND.get_logger('whisper', badge);

  help = CND.get_logger('help', badge);

  echo = CND.echo.bind(CND);

  suspend = require('coffeenode-suspend');

  step = suspend.step;

  levelup = require('levelup');

  levelfs = require('level-filesystem');

  add_writestream = require('level-writestream');

  dump = function(db, handler) {
    var D, input;
    D = require('pipedreams');
    input = db.createReadStream();
    return input.pipe(D.$show()).pipe(D.$on_end(function() {
      if (handler != null) {
        return handler();
      }
    }));
  };

  this.new_db = function(format, route) {
    var backend;
    switch (format) {
      case 'level':
        backend = require('leveldown');
        break;
      case 'json':
        backend = require('jsondown');
        break;
      case 'memory':
        backend = require('memdown');
        break;
      case 'sqlite':
        backend = require('sqldown');
        break;
      default:
        throw new Error("unknown DB format " + (rpr(format)));
    }
    return add_writestream(levelup(route, {
      db: backend
    }));
  };

  this._demo = function() {
    return step((function(_this) {
      return function*(resume) {
        var data, db, i, idx, j, len, name, names, results, route, settings, stat, xfs;
        db = _this.new_db('sqlite', '/tmp/foo.db');
        xfs = levelfs(db);
        settings = {
          encoding: 'utf-8'
        };
        (yield xfs.mkdir('/even', resume));
        (yield xfs.mkdir('/odd', resume));
        for (idx = i = 0; i <= 10; idx = ++i) {
          route = "hello-world-" + idx + ".txt";
          route = idx % 2 === 0 ? "/even/" + route : "/odd/" + route;
          data = "foo " + idx + " bar " + idx + " baz " + idx;
          (yield xfs.writeFile(route, data, settings, resume));
        }
        names = (yield xfs.readdir('/even/', resume));
        help(names);
        results = [];
        for (j = 0, len = names.length; j < len; j++) {
          name = names[j];
          route = "/even/" + name;
          stat = (yield xfs.stat(route, resume));
          results.push(help(route, stat.isFile(), stat.isDirectory()));
        }
        return results;
      };
    })(this));
  };

  if (module.parent == null) {
    this._demo();
  }

}).call(this);

//# sourceMappingURL=../sourcemaps/main.js.map