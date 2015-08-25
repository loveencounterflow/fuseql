



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


#-----------------------------------------------------------------------------------------------------------
@write = ( filename, data, settings, handler ) ->
  switch arity = arguments.length
    when 3
      handler   = settings
      settings  = {}
    when 4
      null
    else
      throw new Error "expected 3 or 4 arguments, got #{arity}"
  encoding  = settings[ 'encoding'  ]
  # mode      = settings[ 'mode'      ]
  # flag      = settings[ 'flag'      ]
  # key

HOLLERITH                 = require 'HOLLERITH'
CND.dir CODEC = HOLLERITH[ 'CODEC' ]
debug '©r4Y4M', CODEC[ 'sentinels' ]
debug '©r4Y4M', CODEC[ 'typemarkers' ]
