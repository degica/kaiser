require 'kaiser/version'
require 'kaiser/kaiserfile'
require 'kaiser/cli'
require 'kaiser/after_dotter'
require 'kaiser/dotter'

require 'kaiser/config'

require 'kaiser/cmds/init'
require 'kaiser/cmds/deinit'
require 'kaiser/cmds/up'
require 'kaiser/cmds/down'
require 'kaiser/cmds/shutdown'
require 'kaiser/cmds/db_save'
require 'kaiser/cmds/db_load'
require 'kaiser/cmds/db_reset'
require 'kaiser/cmds/db_reset_hard'
require 'kaiser/cmds/logs'
require 'kaiser/cmds/attach'
require 'kaiser/cmds/login'
require 'kaiser/cmds/show'
require 'kaiser/cmds/set'

SUB_COMMANDS = {
  init: Kaiser::CMD::Init,
  deinit: Kaiser::CMD::Deinit,
  up: Kaiser::CMD::Up,
  shutdown: Kaiser::CMD::Shutdown,
  db_save: Kaiser::CMD::DbSave,
  db_load: Kaiser::CMD::DbLoad,
  db_reset: Kaiser::CMD::DbReset,
  db_reset_hard: Kaiser::CMD::DbResetHard,
  logs: Kaiser::CMD::Logs,
  attach: Kaiser::CMD::Attach,
  login: Kaiser::CMD::Login,
  show: Kaiser::CMD::Show,
  set: Kaiser::CMD::Set
}.freeze

# Kaiser
module Kaiser
end
