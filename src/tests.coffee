






############################################################################################################
njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr.bind CND
badge                     = 'FUSEQL/tests'
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
later                     = suspend.immediately
#...........................................................................................................
test                      = require 'guy-test'
TEMP                      = require 'temp'
#...........................................................................................................
FUSEQL                    = require './main'
HOLLERITH                 = require 'hollerith'



#-----------------------------------------------------------------------------------------------------------
@[ 'first' ] = ( T, done ) ->
  db = @_new_db()
  step ( resume ) =>
    response = yield FUSEQL.writeFile db, '/welcome.txt', """helo world! ሰላም! 你好世界!""", resume
    debug '©wgGQZ', response
    T.eq 1, 1
    @_discard db, done

#-----------------------------------------------------------------------------------------------------------
@_new_db = ->
  db_route    = TEMP.mkdirSync 'fuseql-test-db-'
  db_settings = size: 500
  R           = HOLLERITH.new_db db_route, db_settings
  R           = FUSEQL.prepare_db R
  help "created temporary DB at #{db_route}"
  return R

#-----------------------------------------------------------------------------------------------------------
@_discard = ( db, handler ) -> db[ '%self' ].close handler


############################################################################################################
unless module.parent?
  test @, 'timeout': 2500
  # step ( resume ) =>
  #   debug '©17T31', temp_route



