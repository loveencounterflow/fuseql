(function() {
  var CND, FUSE, SQLITE3, alert, badge, db, db_route, debug, echo, fallback_gid, fallback_mode, fallback_size, fallback_time, fallback_uid, help, info, log, mount_locator, mount_route, njs_path, rpr, sqlitefs, urge, warn, whisper;

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

  FUSE = require('fuse-bindings');

  mount_route = './mnt';

  mount_locator = njs_path.resolve(__dirname, mount_route);

  SQLITE3 = (require('sqlite3')).verbose();

  db_route = 'fs.db';

  warn("removing DB at " + db_route);

  (require('fs')).unlinkSync(db_route);

  db = new SQLITE3.Database(db_route);

  fallback_time = +new Date();

  fallback_size = +new Date();

  fallback_mode = 0x81a4;

  fallback_uid = process.getuid();

  fallback_gid = process.getgid();

  db.serialize(function() {
    var i, idx, statement;
    db.run('CREATE TABLE IF NOT EXISTS lorem (info TEXT)');
    db.run("CREATE TABLE IF NOT EXISTS main (\n    home    TEXT    NOT NULL\n  , name    TEXT    NOT NULL\n  , mtime   INTEGER NOT NULL DEFAULT " + fallback_time + "\n  , atime   INTEGER NOT NULL DEFAULT " + fallback_time + "\n  , ctime   INTEGER NOT NULL DEFAULT " + fallback_time + "\n  , size    INTEGER NOT NULL DEFAULT " + fallback_size + "\n  , mode    INTEGER NOT NULL DEFAULT " + fallback_mode + "\n  , uid     INTEGER NOT NULL DEFAULT " + fallback_uid + "\n  , gid     INTEGER NOT NULL DEFAULT " + fallback_gid + "\n  -- , content BLOB\n  , content TEXT DEFAULT ''\n  , PRIMARY KEY ( home, name )\n  )");
    statement = db.prepare('INSERT INTO main ( home, name, content ) VALUES ( ?, ?, ? )');
    for (idx = i = 0; i <= 10; idx = ++i) {
      statement.run("/", "file-" + idx + ".txt", "Ipsum " + idx);
    }
    return statement.finalize();
  });

  sqlitefs = {
    readdir: function(route, handler) {
      var Z, on_data, sql;
      echo("readdir         " + (rpr(route)));
      sql = "SELECT  home, name\nFROM    main\nWHERE   home = ?";
      Z = [];
      on_data = function(error, record) {
        var home, name;
        if (error != null) {
          throw error;
        }
        home = record.home, name = record.name;
        route = home + name;
        return Z.push(route);
      };
      db.each(sql, route, on_data, (function(_this) {
        return function(error, count) {
          if (error != null) {
            throw error;
          }
          help("retrieved " + count + " records");
          debug('©U47Yh', Z);
          return handler(null, Z);
        };
      })(this));
    },
    getattr: function(route, handler) {
      var home, name, sql;
      info("getattr         " + (rpr(route)));
      switch (route) {
        case '/':
          handler(null, {
            mtime: new Date(),
            atime: new Date(),
            ctime: new Date(),
            size: 100,
            mode: 16877,
            uid: process.getuid(),
            gid: process.getgid()
          });
          break;
        default:
          if (!/^\/[^\/]+/.test(route)) {
            return handler(new Error("illegal route " + (rpr(route))));
          }
          home = route[0];
          name = route.slice(1);
          sql = "SELECT  mtime, atime, ctime, size, mode, uid, gid\nFROM    main\nWHERE   home = ? AND name = ?";
          db.get(sql, home, name, function(error, record) {
            var file_description;
            if (error != null) {
              throw error;
            }
            if (record == null) {
              return handler(null);
            }
            debug('©nUEmT', record);
            file_description = {
              mtime: new Date(record['mtime']),
              atime: new Date(record['atime']),
              ctime: new Date(record['ctime']),
              size: record['size'],
              mode: record['mode'],
              uid: record['uid'],
              gid: record['gid']
            };
            debug('©hFS9F', file_description);
            return handler(null, file_description);
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
        return handler(null);
      }
      buf.write(content);
      return handler(content.length);
    }
  };

  FUSE.mount(mount_route, require('./demofs'));

  process.on('SIGINT', function() {
    info("unmounting...");
    db.close();
    FUSE.unmount(mount_route, function() {
      info("done");
      process.exit();
    });
  });

}).call(this);

//# sourceMappingURL=../sourcemaps/main.js.map