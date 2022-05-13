require 'simplecov'
SimpleCov.start unless SimpleCov.running

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rspec'
require 'active_record'
require 'schema_plus_default_expr'
require 'schema_dev/rspec'

SchemaDev::Rspec.setup

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.warnings = true

  config.around do |example|
    begin
      example.run
    ensure
      apply_migration do
        ActiveRecord::Base.connection.tables.each do |table|
          drop_table table, force: :cascade
        end
      end
    end
  end
end

def stub_model(name, base = ActiveRecord::Base, &block)
  klass = Class.new(base)

  if block_given?
    klass.instance_eval(&block)
  end

  stub_const(name, klass)
end

def apply_migration(&block)
  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Schema.define do
      instance_eval &block
    end
  end
end

SimpleCov.command_name "[ruby#{RUBY_VERSION}-activerecord#{::ActiveRecord.version}-#{ActiveRecord::Base.connection.adapter_name}]"
