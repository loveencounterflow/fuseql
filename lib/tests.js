(function() {
  var CND, FakeLevelDOWN, alert, badge, db, db_route, debug, echo, help, info, levelup, log, njs_path, rpr, urge, warn, whisper;

  njs_path = require('path');

  CND = require('cnd');

  rpr = CND.rpr.bind(CND);

  badge = 'FUSEQL/tests';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  urge = CND.get_logger('urge', badge);

  whisper = CND.get_logger('whisper', badge);

  help = CND.get_logger('help', badge);

  echo = CND.echo.bind(CND);

  FakeLevelDOWN = require('./main');

  levelup = require('levelup');

  db_route = njs_path.join(__dirname, '../test.db');

  db = levelup(db_route, {
    db: function(location) {
      return new FakeLevelDOWN(location);
    }
  });

  db.put('foo', 'bar', function(error) {
    if (error != null) {
      throw error;
    }
    db.get('foo', function(error, value) {
      if (error != null) {
        throw error;
      }
      help(rpr(value));
      return null;
    });
    return null;
  });

}).call(this);

//# sourceMappingURL=../sourcemaps/tests.js.map