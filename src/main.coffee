



############################################################################################################
njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr.bind CND
badge                     = 'FUSE/run'
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
#...........................................................................................................
SQLITE3   = ( require 'sqlite3' ).verbose()
db_route  = 'fs.db'
#...........................................................................................................
warn "removing DB at #{db_route}"
( require 'fs' ).unlinkSync db_route
#...........................................................................................................
db        = new SQLITE3.Database db_route
# db        = new SQLITE3.Database ':memory:'


fallback_time = 0
fallback_size = 0
fallback_mode = 0o100644
fallback_uid  = 1000
fallback_gid  = 1000


db.serialize ->
  db.run 'CREATE TABLE IF NOT EXISTS lorem (info TEXT)'
  db.run """
  CREATE TABLE IF NOT EXISTS main (
      home    TEXT    NOT NULL
    , name    TEXT    NOT NULL
    , mtime   INTEGER NOT NULL DEFAULT #{fallback_time}
    , atime   INTEGER NOT NULL DEFAULT #{fallback_time}
    , ctime   INTEGER NOT NULL DEFAULT #{fallback_time}
    , size    INTEGER NOT NULL DEFAULT #{fallback_size}
    , mode    INTEGER NOT NULL DEFAULT #{fallback_mode}
    , uid     INTEGER NOT NULL DEFAULT #{fallback_uid}
    , gid     INTEGER NOT NULL DEFAULT #{fallback_gid}
    -- , content BLOB
    , content TEXT DEFAULT ''
    , PRIMARY KEY ( home, name )
    )
  """
  statement = db.prepare 'INSERT INTO main ( home, name, content ) VALUES ( ?, ?, ? )'
  for idx in [ 0 .. 10 ]
    statement.run "/", "file-#{idx}.txt", "Ipsum #{idx}"
  statement.finalize()
  # db.each 'SELECT rowid AS id, info FROM lorem', ( error, record ) ->
  #   throw error if error?
  #   debug '©ZYjLy', record
  #   help record.id + ': ' + record.info
  #   return null
  # return null


#-----------------------------------------------------------------------------------------------------------
sqlitefs =

  #---------------------------------------------------------------------------------------------------------
  readdir: ( route, handler ) ->
    echo 'readdir(%s)', route
    sql = """
      SELECT  home, name
      FROM    main
      WHERE   home = ?
      """
    Z = []
    # db.serialize =>
      # statement = db.prepare sql
      # statement.run route
    on_data = ( error, record ) ->
      throw error if error?
      { home, name, } = record
      route = home + name
      Z.push route
      debug '©ZYjLy', record
    db.each sql, route, on_data, ( error, count ) =>
      throw error if error?
      help "retrieved #{count} records"
      handler null, Z
  # if route == '/'
    #   filenames = ( "file-#{idx}" for idx in [ 0 .. 10 ] )
    #   filenames.push 'test'
    #   return handler null, filenames
    # handler null
    return

  #---------------------------------------------------------------------------------------------------------
  getattr: ( route, handler ) ->
    info "getattr #{rpr route}"
    switch route
      when '/' #, '/._.', '/.hidden', '/mach_kernel'
        handler null,
          mtime: new Date
          atime: new Date
          ctime: new Date
          size: 100
          mode: 16877
          uid: process.getuid()
          gid: process.getgid()
      else
        unless ( /^\/[^\/]+/ ).test route
          return handler new Error "illegal route #{rpr route}"
        home = route[ 0 ]
        name = route[ 1 .. ]
        sql = """
          SELECT  home, name, mtime, atime, ctime, size, mode, uid, gid, content
          FROM    main
          WHERE   home = ? AND name = ?
          """
        db.get sql, home, name, ( error, record ) ->
          throw error if error?
          return handler null unless record?
          debug '©nUEmT', record
          { home
            name
            mtime
            atime
            ctime
            size
            mode
            uid
            gid
            content   } = record
          # route         = home + name
          handler null,
            mtime:  mtime
            atime:  atime
            ctime:  ctime
            size:   size
            mode:   mode
            uid:    uid
            gid:    gid
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

#-----------------------------------------------------------------------------------------------------------
# FUSE.mount mount_route, demofs
FUSE.mount mount_route, sqlitefs

#-----------------------------------------------------------------------------------------------------------
process.on 'SIGINT', ->
  info "unmounting..."
  db.close()
  FUSE.unmount mount_route, ->
    info "done"
    process.exit()
    return
  return























