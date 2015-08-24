



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
# later                     = setImmediate
#...........................................................................................................
# FUSE                      = require 'fuse-bindings'
# mount_route               = './mnt'
# mount_locator             = njs_path.resolve __dirname, mount_route
#...........................................................................................................
SQLITE3                   = ( require 'sqlite3' ).verbose()
ABSTRACTLEVELDOWN         = require 'abstract-leveldown'
AbstractLevelDOWN         = ABSTRACTLEVELDOWN.AbstractLevelDOWN

#-----------------------------------------------------------------------------------------------------------
@_init = ->
  """Optionally remove existing DB file; create DB file if missing; create `main` table if 
  missing."""

#-----------------------------------------------------------------------------------------------------------
@put = ( db, key, value, handler ) ->

#-----------------------------------------------------------------------------------------------------------
@get = ( db, key, handler ) ->

#-----------------------------------------------------------------------------------------------------------
@delete = ( db, key, handler ) ->

#-----------------------------------------------------------------------------------------------------------
@create_readstream = ( db, settings, handler ) ->

#-----------------------------------------------------------------------------------------------------------
@create_keystream = ( db, settings, handler ) ->

#-----------------------------------------------------------------------------------------------------------
@create_valuestream = ( db, settings, handler ) ->



###
  db.run """
    CREATE TABLE IF NOT EXISTS `demo` (
      `key`   BLOB PRIMARY KEY,
      `value` BLOB )
      """
  """
    INSERT OR REPLACE INTO `demo` ( `key`, `value` ) 
    VALUES ( ?, ? )
    """
###

#-----------------------------------------------------------------------------------------------------------
FakeLevelDOWN = ( location ) ->
  AbstractLevelDOWN.call this, location
  return

#-----------------------------------------------------------------------------------------------------------
( require 'util' ).inherits FakeLevelDOWN, AbstractLevelDOWN


#-----------------------------------------------------------------------------------------------------------
FakeLevelDOWN::_open = (options, callback) ->
  # initialise a memory storage object
  @_store = {}
  # optional use of nextTick to be a nice async citizen
  process.nextTick (->
    callback null, this
    return
  ).bind(this)
  return

#-----------------------------------------------------------------------------------------------------------
FakeLevelDOWN::_put = (key, value, options, callback) ->
  key = '_' + key
  # safety, to avoid key='__proto__'-type skullduggery 
  @_store[key] = value
  process.nextTick callback
  return

#-----------------------------------------------------------------------------------------------------------
FakeLevelDOWN::_get = (key, options, callback) ->
  value = @_store['_' + key]
  if value == undefined
    # 'NotFound' error, consistent with LevelDOWN API
    return process.nextTick(->
      callback new Error('NotFound')
      return
    )
  process.nextTick ->
    callback null, value
    return
  return

#-----------------------------------------------------------------------------------------------------------
FakeLevelDOWN::_del = (key, options, callback) ->
  delete @_store['_' + key]
  process.nextTick callback
  return

#-----------------------------------------------------------------------------------------------------------
module.exports = FakeLevelDOWN

