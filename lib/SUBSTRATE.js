(function() {
  var CND, alert, badge, debug, echo, help, info, log, njs_path, rpr, urge, warn, whisper;

  njs_path = require('path');

  CND = require('cnd');

  rpr = CND.rpr.bind(CND);

  badge = 'FUSEQL/SUBSTRATE';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  urge = CND.get_logger('urge', badge);

  whisper = CND.get_logger('whisper', badge);

  help = CND.get_logger('help', badge);

  echo = CND.echo.bind(CND);

  this.init = function(settings, handler) {
    return "Optionally remove existing DB file; create DB file if missing; create `main` table if \nmissing.";
  };

  this.put = function(db, key, value, handler) {};

  this.get = function(db, key, handler) {};

  this["delete"] = function(db, key, handler) {};

  this.create_readstream = function(db, settings, handler) {};

  this.create_keystream = function(db, settings, handler) {};

  this.create_valuestream = function(db, settings, handler) {};

}).call(this);

//# sourceMappingURL=../sourcemaps/SUBSTRATE.js.map