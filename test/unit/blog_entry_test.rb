require 'test_helper'

class BlogEntryTest < ActiveSupport::TestCase
  context "A BlogEntry" do
    setup do
      @blog_entry = BlogEntry.make
    end

    subject { @blog_entry }

    should_belong_to :profile, :project
    should_have_many :remarks
    should_validate_presence_of :profile, :project, :title, :content
  end
end
