(function() {
  var demofs;

  demofs = {
    readdir: function(route, handler) {
      var filenames, idx;
      echo('readdir(%s)', route);
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
      info('getattr(%s)', route);
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
      info('open(%s, %d)', route, flags);
      handler(0, 42);
    },
    read: function(route, fd, buf, len, pos, handler) {
      var content, locator, relative_route;
      info('read(%s, %d, %d, %d)', route, fd, len, pos);
      relative_route = route;
      if (relative_route[0] !== '/') {
        relative_route = "/" + route;
      }
      if (relative_route[0] !== '.') {
        relative_route = "." + route;
      }
      locator = njs_path.resolve(mount_locator, relative_route);
      info('©jQFeh', relative_route);
      info('©Qpb1T', mount_locator);
      info('©zZVe3', locator);
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