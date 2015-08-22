(function() {
  var CND, FUSE, Proxy, SQLITE3, alert, badge, db, db_route, debug, demofs, echo, fallback_gid, fallback_mode, fallback_size, fallback_time, fallback_uid, handler, help, info, is_valid_route, later, log, mount_locator, mount_route, njs_path, result_codes, rpr, split_route, sqlitefs, urge, warn, whisper;

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

  later = setImmediate;

  FUSE = require('fuse-bindings');

  mount_route = './mnt';

  mount_locator = njs_path.resolve(__dirname, mount_route);

  SQLITE3 = (require('sqlite3')).verbose();

  db_route = 'fs.db';

  warn("removing DB at " + db_route);

  (require('fs')).unlinkSync(db_route);

  db = new SQLITE3.Database(db_route);

  fallback_time = +new Date();

  fallback_size = 100;

  fallback_mode = 0x81a4;

  fallback_uid = process.getuid();

  fallback_gid = process.getgid();

  db.serialize(function() {
    var content, i, idx, length, name, statement;
    db.run('CREATE TABLE IF NOT EXISTS lorem (info TEXT)');
    db.run("CREATE TABLE IF NOT EXISTS main (\n    home    TEXT    NOT NULL\n  , name    TEXT    NOT NULL\n  , mtime   INTEGER NOT NULL DEFAULT " + fallback_time + "\n  , atime   INTEGER NOT NULL DEFAULT " + fallback_time + "\n  , ctime   INTEGER NOT NULL DEFAULT " + fallback_time + "\n  , size    INTEGER NOT NULL DEFAULT " + fallback_size + "\n  , mode    INTEGER NOT NULL DEFAULT " + fallback_mode + "\n  , uid     INTEGER NOT NULL DEFAULT " + fallback_uid + "\n  , gid     INTEGER NOT NULL DEFAULT " + fallback_gid + "\n  -- , content BLOB\n  , content TEXT DEFAULT ''\n  , PRIMARY KEY ( home, name )\n  )");
    statement = db.prepare('INSERT INTO main ( home, name, size, content ) VALUES ( ?, ?, ?, ? )');
    for (idx = i = 0; i <= 10; idx = ++i) {
      name = "file-" + idx + ".txt";
      content = "hello world from " + name + "\n";
      length = Buffer.byteLength(content, 'utf-8');
      statement.run("/", name, length, content);
    }
    return statement.finalize();
  });

  result_codes = {
    'ok': 0,
    'error': -1
  };

  is_valid_route = function(route) {
    return /^\/[^\/]+/.test(route);
  };

  split_route = function(route) {
    return [route[0], route.slice(1)];
  };

  sqlitefs = {
    displayFolder: true,
    force: true,
    options: ['direct_io', 'allow_other', 'fsname="fuseql"'],
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
        return Z.push(name);
      };
      db.each(sql, route, on_data, (function(_this) {
        return function(error, count) {
          if (error != null) {
            throw error;
          }
          help("retrieved " + count + " records");
          debug('©U47Yh', Z);
          return handler(result_codes['ok'], Z);
        };
      })(this));
    },
    getattr: function(route, handler) {
      var home, name, ref, sql;
      info("getattr         " + (rpr(route)));
      switch (route) {
        case '/':
          handler(result_codes['ok'], {
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
          if (!is_valid_route(route)) {
            return handler(result_codes['error'], "illegal route " + (rpr(route)));
          }
          ref = split_route(route), home = ref[0], name = ref[1];
          sql = "SELECT  mtime, atime, ctime, size, mode, uid, gid\nFROM    main\nWHERE   home = ? AND name = ?";
          db.get(sql, home, name, function(error, record) {
            var file_description;
            if (error != null) {
              throw error;
            }
            if (record == null) {
              return handler(result_codes['ok']);
            }
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
            return handler(result_codes['ok'], file_description);
          });
      }
      return null;
    },
    open: function(route, flags, handler) {
      info("open            " + (rpr(route)) + ", " + (rpr(flags)));
      handler(result_codes['ok'], 42);
    },
    read: function(route, fd, buffer, length, position, handler) {
      var home, name, ref, sql;
      info("read            " + (rpr(route)) + ", " + (rpr(fd)) + ", " + (rpr(buffer)) + ", " + (rpr(length)) + ", " + (rpr(position)));
      if (!is_valid_route(route)) {
        return handler(result_codes['error'], "illegal route " + (rpr(route)));
      }
      ref = split_route(route), home = ref[0], name = ref[1];
      sql = "SELECT  content\nFROM    main\nWHERE   home = ? AND name = ?";
      db.get(sql, home, name, function(error, record) {
        var content;
        if (error != null) {
          throw error;
        }
        if (record == null) {
          return handler(result_codes['ok']);
        }
        debug('©B30YQ', record);
        content = record.content;
        content = content.slice(position);
        if (content.length === 0) {
          return handler(0);
        }

        /* TAINT content must not be longer than buffer */
        buffer.write(content, 'utf-8');
        return handler(Buffer.byteLength(content, 'utf-8'));
      });
      return null;
    },
    write: function(route, fd, buffer, length, position, handler) {
      var data;
      info("write           " + (rpr(route)) + ", " + (rpr(fd)) + ", " + (rpr(buffer)) + ", " + (rpr(length)) + ", " + (rpr(position)));
      data = buffer.slice(0, length);
      debug('©pqgx3', data);
      debug('©pqgx3', data.toString());
      return handler(10);
    },
    access: function(route, mode, handler) {
      info("access          " + (rpr(route)) + ", " + (rpr(mode)));
      return handler(result_codes['ok']);
    },
    release: function(route, fd, handler) {
      info("release         " + (rpr(route)) + ", " + (rpr(fd)));
      return handler(result_codes['ok']);
    },
    statfs: function(route, handler) {
      var fs_description;
      info("statfs          " + (rpr(route)));
      fs_description = {
        bsize: 1000000,
        frsize: 1000000,
        blocks: 1000000,
        bfree: 1000000,
        bavail: 1000000,
        files: 1000000,
        ffree: 1000000,
        favail: 1000000,
        fsid: 1000000,
        flag: 1000000,
        namemax: 1000000
      };
      return handler(result_codes['ok'], fs_description);
    }
  };

  if (global.Proxy.create != null) {
    Proxy = require('harmony-proxy');
  }

  handler = {
    get: function(target, key) {
      warn('>>>', key);
      return target[key];
    }
  };

  demofs = new Proxy(require('./demofs'), handler);

  FUSE.mount(mount_route, demofs);

  process.on('SIGINT', function() {
    warn("unmounting...");
    db.close();
    FUSE.unmount(mount_route, function() {
      info("done");
      process.exit();
    });
  });

}).call(this);

//# sourceMappingURL=../sourcemaps/main.js.map