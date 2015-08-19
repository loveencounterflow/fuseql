(function() {
  var CND, FUSE, alert, badge, debug, demofs, echo, help, info, log, mount_locator, mount_route, njs_path, rpr, urge, warn, whisper;

  njs_path = require('path');

  CND = require('cnd');

  rpr = CND.rpr.bind(CND);

  badge = 'FUSEQL/demofs';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  urge = CND.get_logger('urge', badge);

  whisper = CND.get_logger('whisper', badge);

  help = CND.get_logger('help', badge);

  echo = CND.echo.bind(CND);

  FUSE = require('fuse-bindings');

  mount_route = './mnt';

  mount_locator = njs_path.resolve(__dirname, mount_route);

  module.exports = demofs = {
    readdir: function(route, handler) {
      var filenames, idx;
      echo("readdir         " + (rpr(route)));
      if (route === '/') {
        filenames = (function() {
          var i, results;
          results = [];
          for (idx = i = 0; i <= 10; idx = ++i) {
            results.push("file-" + idx);
          }
          return results;
        })();
        filenames.push('test');
        return handler(null, filenames);
      }
      handler(null);
    },
    getattr: function(route, handler) {
      info("getattr         " + (rpr(route)));
      switch (route) {
        case '/':
          handler(0, {
            mtime: new Date,
            atime: new Date,
            ctime: new Date,
            size: 100,
            mode: 16877,
            uid: process.getuid(),
            gid: process.getgid()
          });
          break;
        case '/test':
          handler(0, {
            mtime: new Date,
            atime: new Date,
            ctime: new Date,
            size: 12,
            mode: 33188,
            uid: process.getuid(),
            gid: process.getgid()
          });
          break;
        default:
          handler(0, {
            mtime: new Date,
            atime: new Date,
            ctime: new Date,
            size: 1234,
            mode: 33188,
            uid: process.getuid(),
            gid: process.getgid()
          });
      }
      return null;
    },
    open: function(route, flags, handler) {
      info("open            " + (rpr(route)) + ", " + (rpr(flags)));
      handler(0, 42);
    },
    read: function(route, fd, buf, len, pos, handler) {
      var content, locator, relative_route;
      info("read            " + (rpr(route)) + ", " + (rpr(fd)) + ", " + (rpr(buf)) + ", " + (rpr(len)) + ", " + (rpr(pos)));
      relative_route = route;
      if (relative_route[0] !== '/') {
        relative_route = "/" + route;
      }
      if (relative_route[0] !== '.') {
        relative_route = "." + route;
      }
      locator = njs_path.resolve(mount_locator, relative_route);
      content = "hello world\nfrom " + locator + "\n\n";
      content = content.slice(pos);
      if (!content) {
        return handler(0);
      }
      buf.write(content);
      return handler(content.length);
    }
  };

}).call(this);

//# sourceMappingURL=../sourcemaps/demofs.js.map