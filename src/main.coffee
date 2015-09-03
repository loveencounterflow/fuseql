



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
suspend                   = require 'coffeenode-suspend'
step                      = suspend.step
# immediately               = suspend.immediately
# after                     = suspend.after
# sleep                     = suspend.sleep
# later                     = setImmediate

levelup                   = require 'levelup'
levelfs                   = require 'level-filesystem'
add_writestream           = require 'level-writestream'

#-----------------------------------------------------------------------------------------------------------
dump = ( db, handler ) ->
  D             = require 'pipedreams'
  input = db.createReadStream()
  input
    .pipe D.$show()
    .pipe D.$on_end ->
      handler() if handler?

#-----------------------------------------------------------------------------------------------------------
@new_db = ( format, route ) ->
  #.........................................................................................................
  switch format
    when 'level'  then backend = require 'leveldown'
    when 'json'   then backend = require 'jsondown'
    when 'memory' then backend = require 'memdown'
    when 'sqlite' then backend = require 'sqldown'
    else throw new Error "unknown DB format #{rpr format}"
  #.........................................................................................................
  # db_route      = njs_path.join __dirname, "db.#{extension ? format}"
  return add_writestream levelup route, db: backend

#-----------------------------------------------------------------------------------------------------------
@_demo = ->
  step ( resume ) =>
    # db        = @new_db 'json', '/tmp/foo.json'
    db        = @new_db 'sqlite', '/tmp/foo.db'
    xfs       = levelfs db
    settings  =
      encoding: 'utf-8'
    yield xfs.mkdir '/even', resume
    yield xfs.mkdir '/odd',  resume
    for idx in [ 0 .. 10 ]
      route = "hello-world-#{idx}.txt"
      route = if ( idx % 2 is 0 ) then "/even/#{route}" else "/odd/#{route}"
      data  = "foo #{idx} bar #{idx} baz #{idx}"
      yield xfs.writeFile route, data, settings, resume
    names = yield xfs.readdir '/even/', resume
    help names
    for name in names
      route = "/even/#{name}"
      stat  = yield xfs.stat route, resume 
      help route, stat.isFile(), stat.isDirectory()

############################################################################################################
unless module.parent?
  @_demo()





