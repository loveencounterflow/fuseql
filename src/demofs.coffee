


#-----------------------------------------------------------------------------------------------------------
demofs =

  #---------------------------------------------------------------------------------------------------------
  readdir: ( route, handler ) ->
    echo 'readdir(%s)', route
    if route == '/'
      filenames = ( "file-#{idx}" for idx in [ 0 .. 10 ] )
      filenames.push 'test'
      return handler null, filenames
    handler null
    return

  #---------------------------------------------------------------------------------------------------------
  getattr: (route, handler) ->
    info 'getattr(%s)', route
    switch route
      when '/'
        handler 0,
          mtime: new Date
          atime: new Date
          ctime: new Date
          size: 100
          mode: 16877
          uid: process.getuid()
          gid: process.getgid()
      when '/test'
        handler 0,
          mtime: new Date
          atime: new Date
          ctime: new Date
          size: 12
          mode: 33188
          uid: process.getuid()
          gid: process.getgid()
      else
        handler 0,
          mtime: new Date
          atime: new Date
          ctime: new Date
          size: 1234
          mode: 33188
          uid: process.getuid()
          gid: process.getgid()
      # else
      #   handler FUSE.ENOENT
    return null

  #---------------------------------------------------------------------------------------------------------
  open: (route, flags, handler) ->
    info 'open(%s, %d)', route, flags
    handler 0, 42
    # 42 is an fd
    return

  #---------------------------------------------------------------------------------------------------------
  read: ( route, fd, buf, len, pos, handler ) ->
    info 'read(%s, %d, %d, %d)', route, fd, len, pos
    relative_route  = route
    relative_route  = "/#{route}" unless relative_route[ 0 ] is '/'
    relative_route  = ".#{route}" unless relative_route[ 0 ] is '.'
    locator         = njs_path.resolve mount_locator, relative_route
    info '©jQFeh', relative_route
    info '©Qpb1T', mount_locator
    info '©zZVe3', locator
    content = """
      hello world
      from #{locator}
      \n"""
    content = content.slice(pos)
    if !content
      return handler(0)
    buf.write content
    handler content.length
