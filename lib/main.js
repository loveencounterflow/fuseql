(function() {
  var CND, CODEC, HOLLERITH, alert, badge, debug, echo, help, info, log, njs_path, rpr, urge, warn, whisper;

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

  this.write = function(filename, data, settings, handler) {
    var arity, encoding;
    switch (arity = arguments.length) {
      case 3:
        handler = settings;
        settings = {};
        break;
      case 4:
        null;
        break;
      default:
        throw new Error("expected 3 or 4 arguments, got " + arity);
    }
    return encoding = settings['encoding'];
  };

  HOLLERITH = require('HOLLERITH');

  CND.dir(CODEC = HOLLERITH['CODEC']);

  debug('©r4Y4M', CODEC['sentinels']);

  debug('©r4Y4M', CODEC['typemarkers']);

}).call(this);

//# sourceMappingURL=../sourcemaps/main.js.map