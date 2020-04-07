# frozen_string_literal: true

require 'kaiser/error'
require 'kaiser/version'
require 'kaiser/kaiserfile'
require 'kaiser/cli_options'
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
require 'kaiser/cmds/root'

require 'kaiser/plugin'
require 'kaiser/plugins/git_submodule'

# Kaiser
module Kaiser
  SUB_COMMANDS = {
    init: Kaiser::Cmds::Init,
    deinit: Kaiser::Cmds::Deinit,
    up: Kaiser::Cmds::Up,
    down: Kaiser::Cmds::Down,
    shutdown: Kaiser::Cmds::Shutdown,
    db_save: Kaiser::Cmds::DbSave,
    db_load: Kaiser::Cmds::DbLoad,
    db_reset: Kaiser::Cmds::DbReset,
    db_reset_hard: Kaiser::Cmds::DbResetHard,
    logs: Kaiser::Cmds::Logs,
    attach: Kaiser::Cmds::Attach,
    login: Kaiser::Cmds::Login,
    show: Kaiser::Cmds::Show,
    set: Kaiser::Cmds::Set,
    root: Kaiser::Cmds::Root
  }.freeze
end
