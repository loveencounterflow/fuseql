



############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
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
later                     = setImmediate
#...........................................................................................................
SQLITE3                   = require 'sqlite3'
db_route                  = njs_path.join __dirname, '../demo.db'
#...........................................................................................................
if njs_fs.existsSync db_route
  warn "removing DB at #{db_route}"
  njs_fs.unlinkSync db_route
#...........................................................................................................
db        = new SQLITE3.Database db_route
# db        = new SQLITE3.Database ':memory:'


db.serialize ->
  db.run """CREATE TABLE IF NOT EXISTS `demo` (
    `key` BLOB PRIMARY KEY,
    `value` BLOB
    )"""
  statement = db.prepare """INSERT INTO `demo` ( `key`, `value` ) VALUES ( ?, ? )"""
  for idx in [ 0 .. 10 ]
    name      = "nr#{100 - idx}"
    name_bfr  = new Buffer name, 'utf-8'
    value     = "#{idx}"
    value_bfr = new Buffer value, 'utf-8'
    statement.run name_bfr, value_bfr
  statement.finalize()
  #.........................................................................................................
  """INSERT OR REPLACE INTO `demo` ( `key`, `value` ) VALUES ( "a", "c" )"""
  #.........................................................................................................
  sql = """
    SELECT `key`, `value` 
    FROM `demo`
    ORDER BY `key` ASC
    """
  #.........................................................................................................
  db.each sql, ( error, record ) ->
    throw error if error?
    debug '©ZYjLy', record, rpr record[ 'key' ].toString 'utf-8'
    return null
  return null


