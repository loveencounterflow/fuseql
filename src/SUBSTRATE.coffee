

############################################################################################################
njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr.bind CND
badge                     = 'FUSEQL/SUBSTRATE'
log                       = CND.get_logger 'plain',   badge
info                      = CND.get_logger 'info',    badge
alert                     = CND.get_logger 'alert',   badge
debug                     = CND.get_logger 'debug',   badge
warn                      = CND.get_logger 'warn',    badge
urge                      = CND.get_logger 'urge',    badge
whisper                   = CND.get_logger 'whisper', badge
help                      = CND.get_logger 'help',    badge
echo                      = CND.echo.bind CND

#-----------------------------------------------------------------------------------------------------------
@init = ( settings, handler ) ->
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



