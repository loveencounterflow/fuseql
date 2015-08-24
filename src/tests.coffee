






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
FakeLevelDOWN             = require './main'
levelup                   = require 'levelup'

db_route  = njs_path.join __dirname, '../test.db'
db        = levelup db_route, db: ( location ) -> new FakeLevelDOWN location

db.put 'foo', 'bar', ( error ) ->
  throw error if error?
  db.get 'foo', ( error, value ) ->
    throw error if error?
    help rpr value
    return null
  return null





