require File.dirname(__FILE__) + '/../test_helper'

class SearchTest < ActiveSupport::TestCase
  context "A Search" do
    should "search with ThinkingSphinx" do
      ThinkingSphinx.expects(:search).returns([])
      assert Search.new(:q => "query")
    end

    should "accept a page number" do
      ThinkingSphinx.expects(:search).with("query", :page => 3, :per_page => 10).returns([])
      assert Search.new(:q => "query", :page => 3)
    end

    should "accept # results per page" do
      ThinkingSphinx.expects(:search).with("query", :page => 1, :per_page => 20).returns([])
      assert Search.new(:q => "query", :n => 20)
    end
  end
end
