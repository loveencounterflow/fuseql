(function() {
  var ABSTRACTLEVELDOWN, AbstractLevelDOWN, CND, FakeLevelDOWN, SQLITE3, alert, badge, debug, echo, help, info, log, njs_path, rpr, urge, warn, whisper;

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

  SQLITE3 = (require('sqlite3')).verbose();

  ABSTRACTLEVELDOWN = require('abstract-leveldown');

  AbstractLevelDOWN = ABSTRACTLEVELDOWN.AbstractLevelDOWN;

  this._init = function() {
    return "Optionally remove existing DB file; create DB file if missing; create `main` table if \nmissing.";
  };

  this.put = function(db, key, value, handler) {};

  this.get = function(db, key, handler) {};

  this["delete"] = function(db, key, handler) {};

  this.create_readstream = function(db, settings, handler) {};

  this.create_keystream = function(db, settings, handler) {};

  this.create_valuestream = function(db, settings, handler) {};


  /*
    db.run """
      CREATE TABLE IF NOT EXISTS `demo` (
        `key`   BLOB PRIMARY KEY,
        `value` BLOB )
        """
    """
      INSERT OR REPLACE INTO `demo` ( `key`, `value` ) 
      VALUES ( ?, ? )
      """
   */

  FakeLevelDOWN = function(location) {
    AbstractLevelDOWN.call(this, location);
  };

  (require('util')).inherits(FakeLevelDOWN, AbstractLevelDOWN);

  FakeLevelDOWN.prototype._open = function(options, callback) {
    this._store = {};
    process.nextTick((function() {
      callback(null, this);
    }).bind(this));
  };

  FakeLevelDOWN.prototype._put = function(key, value, options, callback) {
    key = '_' + key;
    this._store[key] = value;
    process.nextTick(callback);
  };

  FakeLevelDOWN.prototype._get = function(key, options, callback) {
    var value;
    value = this._store['_' + key];
    if (value === void 0) {
      return process.nextTick(function() {
        callback(new Error('NotFound'));
      });
    }
    process.nextTick(function() {
      callback(null, value);
    });
  };

  FakeLevelDOWN.prototype._del = function(key, options, callback) {
    delete this._store['_' + key];
    process.nextTick(callback);
  };

  module.exports = FakeLevelDOWN;

}).call(this);

//# sourceMappingURL=../sourcemaps/main.js.map