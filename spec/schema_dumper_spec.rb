require 'spec_helper'
require 'stringio'

describe "Schema dump" do
  let(:model) { stub_model('Post') }

  context "with date default", :postgresql => :only do
    before do
      apply_migration do
        create_table :posts, :force => true do |t|
        end
      end
    end

    it "should dump the default hash expr as now()" do
      with_additional_column model, :posted_at, :datetime, :default => :now do
        expect(dump_posts).to match(%r{t\.datetime\s+"posted_at",\s*(?:default:|:default\s*=>)\s*\{\s*(?:expr:|:expr\s*=>)\s*"now\(\)"\s*\}\s*$})
      end
    end

    it "should dump the default hash expr as CURRENT_TIMESTAMP" do
      with_additional_column model, :posted_at, :datetime, :default => { :expr => 'date \'2001-09-28\'' } do
        expect(dump_posts).to match(%r{t\.datetime\s+"posted_at",\s*(?:default:|:default\s*=>).*2001-09-28.*})
      end
    end
  end

  context 'with a complex expression', postgresql: :only do
    before do
      apply_migration do
        create_table :posts, :force => true do |t|
        end
      end
    end

    it "can dump a complex default expression" do
      with_additional_column model, :name, :string, :default => { :expr => 'substring(random()::text from 3 for 6)' } do
        expect(dump_posts).to match(%r{t\.string\s+"name",\s*(?:default:|:default\s*=>)\s*{\s*(?:expr:|:expr\s*=>)\s*"\\"substring\\"\(\(random\(\)\)::text, 3, 6\)"\s*}})
      end
    end
  end

  context "with date default", :sqlite3 => :only do
    before do
      apply_migration do
        create_table :posts, :force => true do |t|
        end
      end
    end

    it "should dump the default hash expr as now" do
      with_additional_column model, :posted_at, :datetime, :default => :now do
        expect(dump_posts).to match(%r{t\.datetime\s+"posted_at",\s*(default:|:default\s*=>)\s*\{\s*(?:expr:|:expr\s*=>)\s*"\(?DATETIME\('now'\)\)?"\s*\}})
      end
    end

    it "should dump the default hash expr string as now" do
      with_additional_column model, :posted_at, :datetime, :default => { :expr => "(DATETIME('now'))" } do
        expect(dump_posts).to match(%r{t\.datetime\s+"posted_at",\s*(default:|:default\s*=>)\s*\{\s*(?:expr:|:expr\s*=>)\s*"\(?DATETIME\('now'\)\)?"\s*\}})
      end
    end

    it "should dump the default value normally" do
      with_additional_column model, :posted_at, :string, :default => "now" do
        expect(dump_posts).to match(%r{t\.string\s*"posted_at",\s*(?:default:|:default\s*=>)\s*"now"})
      end
    end
  end

  it "should leave out :default when default was changed to null" do
    apply_migration do
      create_table :posts, :force => true do |t|
        t.datetime :date_column, default: { expr: :now }
      end

      change_column_default :posts, :date_column, nil
    end
    expect(dump_posts).to match(%r{t\.datetime\s+"date_column"$})
  end

  protected

  def to_regexp(string)
    Regexp.new(Regexp.escape(string))
  end

  def with_additional_column(model, column_name, column_type, options)
    table_columns = model.columns.reject { |column| column.name == 'id' }
    apply_migration do
      create_table model.table_name, :force => true do |t|
        table_columns.each do |column|
          t.column column.name, column.type, :default => column.default
        end
        t.column column_name, column_type, options
      end
    end
    yield
  end

  def dump_schema(opts = {})
    stream                                   = StringIO.new
    ActiveRecord::SchemaDumper.ignore_tables = Array.wrap(opts[:ignore]) || []
    ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, stream)
    stream.string
  end

  def dump_posts
    dump_schema(:ignore => %w[users comments])
  end

end
