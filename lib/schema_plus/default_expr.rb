require 'schema_plus/core'

require_relative 'default_expr/version'
require_relative 'default_expr/middleware'
require_relative 'default_expr/active_record/connection_adapters/column'

SchemaMonkey.register SchemaPlus::DefaultExpr
