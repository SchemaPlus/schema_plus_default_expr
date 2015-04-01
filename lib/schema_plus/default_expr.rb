require 'schema_plus/core'

require_relative 'default_expr/version'

# Load any mixins to ActiveRecord modules, such as:
#
#require_relative 'default_expr/active_record/base'

# Load any middleware, such as:
#
# require_relative 'default_expr/middleware/model'

SchemaMonkey.register SchemaPlus::DefaultExpr
