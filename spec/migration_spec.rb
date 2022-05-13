require 'spec_helper'

describe ActiveRecord::Migration do

  before(:each) do
    apply_migration do
      create_table :posts, :force => true do |t|
        t.string :content
      end
    end
  end

  context "when table is created" do
    let(:model) { stub_model('Post') }

    it "should properly handle default values for booleans" do
      expect {
        recreate_table(model) do |t|
          t.boolean :bool, :default => true
        end
      }.to_not raise_error
      expect(model.create.reload.bool).to be true
    end

    it "should properly handle default values for json (#195)", :postgresql => :only do
      recreate_table(model) do |t|
        t.json :json, :default => {}
      end
      expect(model.create.reload.json).to eq({})
    end

  end

  def recreate_table(model, opts={}, &block)
    apply_migration do
      create_table model.table_name, **opts.merge(:force => true), &block
    end
    model.reset_column_information
  end
end
