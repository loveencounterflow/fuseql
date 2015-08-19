



############################################################################################################
njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr.bind CND
badge                     = 'FUSEQL/main'
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
later                     = setImmediate
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



fallback_time = +new Date()
fallback_size = 100
fallback_mode = 0o100644
fallback_uid  = process.getuid()
fallback_gid  = process.getgid()


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
  statement = db.prepare 'INSERT INTO main ( home, name, size, content ) VALUES ( ?, ?, ?, ? )'
  for idx in [ 0 .. 10 ]
    name    = "file-#{idx}.txt"
    content = """
      hello world from #{name}\n
      """
    length = Buffer.byteLength content, 'utf-8'
    statement.run "/", name, length, content
  statement.finalize()
  # db.each 'SELECT rowid AS id, info FROM lorem', ( error, record ) ->
  #   throw error if error?
  #   debug '©ZYjLy', record
  #   help record.id + ': ' + record.info
  #   return null
  # return null


#-----------------------------------------------------------------------------------------------------------
result_codes =
  'ok':         0
  'error':      -1

#-----------------------------------------------------------------------------------------------------------
is_valid_route = ( route ) -> ( /^\/[^\/]+/ ).test route

#-----------------------------------------------------------------------------------------------------------
split_route = ( route ) -> [ route[ 0 ], route[ 1 .. ], ]

#-----------------------------------------------------------------------------------------------------------
sqlitefs =

  #---------------------------------------------------------------------------------------------------------
  displayFolder:  yes
  force:          yes

  #---------------------------------------------------------------------------------------------------------
  readdir: ( route, handler ) ->
    echo "readdir         #{rpr route}"
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
      # route = home + name
      Z.push name
    db.each sql, route, on_data, ( error, count ) =>
      throw error if error?
      help "retrieved #{count} records"
      debug '©U47Yh', Z
      handler result_codes[ 'ok' ], Z
  # if route == '/'
    #   filenames = ( "file-#{idx}" for idx in [ 0 .. 10 ] )
    #   filenames.push 'test'
    #   return handler result_codes[ 'ok' ], filenames
    # handler result_codes[ 'ok' ]
    return

  #---------------------------------------------------------------------------------------------------------
  getattr: ( route, handler ) ->
    info "getattr         #{rpr route}"
    switch route
      when '/' #, '/._.', '/.hidden', '/mach_kernel'
        handler result_codes[ 'ok' ],
          mtime: new Date()
          atime: new Date()
          ctime: new Date()
          size: 100
          mode: 16877
          uid: process.getuid()
          gid: process.getgid()
      else
        return handler result_codes[ 'error' ], "illegal route #{rpr route}" unless is_valid_route route
        [ home, name, ] = split_route route
        sql = """
          SELECT  mtime, atime, ctime, size, mode, uid, gid
          FROM    main
          WHERE   home = ? AND name = ?
          """
        db.get sql, home, name, ( error, record ) ->
          throw error if error?
          return handler result_codes[ 'ok' ] unless record?
          # debug '©nUEmT', record
          # { home
          #   name
          #   mtime
          #   atime
          #   ctime
          #   size
          #   mode
          #   uid
          #   gid     } = record
          # # route         = home + name
          file_description =
            mtime:  new Date record[ 'mtime' ]
            atime:  new Date record[ 'atime' ]
            ctime:  new Date record[ 'ctime' ]
            size:   record[ 'size'  ]
            mode:   record[ 'mode'  ]
            uid:    record[ 'uid'   ]
            gid:    record[ 'gid'   ]
          debug '©hFS9F', file_description
          handler result_codes[ 'ok' ], file_description
      # else
      #   handler FUSE.ENOENT
    return null

  #---------------------------------------------------------------------------------------------------------
  open: ( route, flags, handler ) ->
    info "open            #{rpr route}, #{rpr flags}"
    # 42 is an fd
    handler result_codes[ 'ok' ], 42
    return

  #---------------------------------------------------------------------------------------------------------
  read: ( route, fd, buffer, length, position, handler ) ->
    info "read            #{rpr route}, #{rpr fd}, #{rpr buffer}, #{rpr length}, #{rpr position}"
    return handler result_codes[ 'error' ], "illegal route #{rpr route}" unless is_valid_route route
    [ home, name, ] = split_route route
    sql             = """
      SELECT  content
      FROM    main
      WHERE   home = ? AND name = ?
      """
    db.get sql, home, name, ( error, record ) ->
      throw error if error?
      return handler result_codes[ 'ok' ] unless record?
      debug '©B30YQ', record
      { content } = record
      content     = content.slice position
      return handler 0 if content.length is 0
      ### TAINT content must not be longer than buffer ###
      buffer.write content, 'utf-8'
      handler Buffer.byteLength content, 'utf-8'
    return null

  #---------------------------------------------------------------------------------------------------------
  write: ( route, fd, buffer, length, position, handler ) ->
    info "write           #{rpr route}, #{rpr fd}, #{rpr buffer}, #{rpr length}, #{rpr position}"
    data = buffer.slice 0, length
    debug '©pqgx3', data
    debug '©pqgx3', data.toString()
    handler 10
    # db.serialize ->
    #   sql = """
    #     INSERT INTO main
    #       ( home, name, size, content )
    #       VALUES ( ?, ?, ?, ? )"""
    #   statement = db.prepare sql
    #   for idx in [ 0 .. 10 ]
    #     name    = "file-#{idx}.txt"
    #     content = """
    #       hello world from #{name}\n
    #       """
    #     length = Buffer.byteLength content, 'utf-8'
    #     statement.run "/", name, length, content
    #   statement.finalize()

  #---------------------------------------------------------------------------------------------------------
  access: ( route, mode, handler ) ->
    info "access          #{rpr route}, #{rpr mode}"
    handler result_codes[ 'ok' ]

  #---------------------------------------------------------------------------------------------------------
  release: ( route, fd, handler ) ->
    info "release         #{rpr route}, #{rpr fd}"
    handler result_codes[ 'ok' ]

  #---------------------------------------------------------------------------------------------------------
  statfs: ( route, handler ) ->
    info "statfs          #{rpr route}"
    fs_description =
      bsize:    1000000
      frsize:   1000000
      blocks:   1000000
      bfree:    1000000
      bavail:   1000000
      files:    1000000
      ffree:    1000000
      favail:   1000000
      fsid:     1000000
      flag:     1000000
      namemax:  1000000
    handler result_codes[ 'ok' ], fs_description

#-----------------------------------------------------------------------------------------------------------
do ->
  names = """
  access chmod chown create destroy fgetattr flush fsync fsyncdir ftruncate getattr getxattr init link
  mkdir mknod open opendir read readdir readlink release releasedir rename rmdir setxattr statfs symlink
  truncate unlink utimens write""".split /\s+/
  for name in names
    continue if sqlitefs[ name ]?
    switch
      when 'init', 'statfs', 'destroy'
        continue
      else
        do ( name ) ->
          message = "not implemented: #{name}"
          sqlitefs[ name ] = ( _..., handler ) ->
            warn message
            handler result_codes[ 'error' ], message

#-----------------------------------------------------------------------------------------------------------
# FUSE.mount mount_route, ( require './demofs' )
FUSE.mount mount_route, sqlitefs

#-----------------------------------------------------------------------------------------------------------
process.on 'SIGINT', ->
  warn "unmounting..."
  db.close()
  FUSE.unmount mount_route, ->
    info "done"
    process.exit()
    return
  return











