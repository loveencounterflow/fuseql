(function() {
  var CND, FUSEQL, HOLLERITH, TEMP, alert, badge, debug, echo, help, info, later, log, njs_path, rpr, step, suspend, test, urge, warn, whisper;

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

  suspend = require('coffeenode-suspend');

  step = suspend.step;

  later = suspend.immediately;

  test = require('guy-test');

  TEMP = require('temp');

  FUSEQL = require('./main');

  HOLLERITH = require('hollerith');

  this['first'] = function(T, done) {
    var db;
    db = this._new_db();
    return step((function(_this) {
      return function*(resume) {
        var response;
        response = (yield FUSEQL.writeFile(db, '/welcome.txt', "helo world! ሰላም! 你好世界!", resume));
        debug('©wgGQZ', response);
        T.eq(1, 1);
        return _this._discard(db, done);
      };
    })(this));
  };

  this._new_db = function() {
    var R, db_route, db_settings;
    db_route = TEMP.mkdirSync('fuseql-test-db-');
    db_settings = {
      size: 500
    };
    R = HOLLERITH.new_db(db_route, db_settings);
    R = FUSEQL.prepare_db(R);
    help("created temporary DB at " + db_route);
    return R;
  };

  this._discard = function(db, handler) {
    return db['%self'].close(handler);
  };

  if (module.parent == null) {
    test(this, {
      'timeout': 2500
    });
  }

}).call(this);

//# sourceMappingURL=../sourcemaps/tests.js.map