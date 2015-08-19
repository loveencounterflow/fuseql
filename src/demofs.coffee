



############################################################################################################
njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr.bind CND
badge                     = 'FUSEQL/demofs'
log                       = CND.get_logger 'plain',   badge
info                      = CND.get_logger 'info',    badge
alert                     = CND.get_logger 'alert',   badge
debug                     = CND.get_logger 'debug',   badge
warn                      = CND.get_logger 'warn',    badge
urge                      = CND.get_logger 'urge',    badge
whisper                   = CND.get_logger 'whisper', badge
help                      = CND.get_logger 'help',    badge
echo                      = CND.echo.bind CND
#...........................................................................................................
# suspend                   = require 'coffeenode-suspend'
# step                      = suspend.step
# immediately               = suspend.immediately
# after                     = suspend.after
# sleep                     = suspend.sleep
#...........................................................................................................
FUSE                      = require 'fuse-bindings'
mount_route               = './mnt'
mount_locator             = njs_path.resolve __dirname, mount_route


#-----------------------------------------------------------------------------------------------------------
module.exports = demofs =

  #---------------------------------------------------------------------------------------------------------
  readdir: ( route, handler ) ->
    echo "readdir         #{rpr route}"
    if route == '/'
      filenames = ( "file-#{idx}" for idx in [ 0 .. 10 ] )
      filenames.push 'test'
      return handler null, filenames
    handler null
    return

  #---------------------------------------------------------------------------------------------------------
  getattr: (route, handler) ->
    info "getattr         #{rpr route}"
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
    info "open            #{rpr route}, #{rpr flags}"
    handler 0, 42
    # 42 is an fd
    return

  #---------------------------------------------------------------------------------------------------------
  read: ( route, fd, buf, len, pos, handler ) ->
    info "read            #{rpr route}, #{rpr fd}, #{rpr buf}, #{rpr len}, #{rpr pos}"
    relative_route  = route
    relative_route  = "/#{route}" unless relative_route[ 0 ] is '/'
    relative_route  = ".#{route}" unless relative_route[ 0 ] is '.'
    locator         = njs_path.resolve mount_locator, relative_route
    # info '©jQFeh', relative_route
    # info '©Qpb1T', mount_locator
    # info '©zZVe3', locator
    content = """
      hello world
      from #{locator}
      \n"""
    content = content.slice(pos)
    if !content
      return handler(0)
    buf.write content
    handler content.length
