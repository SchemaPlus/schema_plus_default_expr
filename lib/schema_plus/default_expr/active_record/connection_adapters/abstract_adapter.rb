module SchemaPlus::DefaultExpr
  module ActiveRecord
    module ConnectionAdapters
      module AbstractAdapter
        def sql_for_function(function)
          # Default nil implementation to be overriden by db adapters.
          # (Keep this here to avoid failure if gem is loaded with mysql2 or
          # other non-supported db adapters.)
        end
      end
    end
  end
end
