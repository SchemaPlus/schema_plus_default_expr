require 'schema_plus/core'

require_relative 'default_expr/version'
require_relative 'default_expr/middleware'
require_relative 'default_expr/active_record/connection_adapters/column'
require_relative 'default_expr/active_record/connection_adapters/postgresql_adapter'
require_relative 'default_expr/active_record/connection_adapters/sqlite3_adapter'

SchemaMonkey.register SchemaPlus::DefaultExpr
