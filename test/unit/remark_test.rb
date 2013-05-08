require 'test_helper'

class RemarkTest < ActiveSupport::TestCase
  context "A Remark" do
    setup do
      @remark = Remark.make
    end

    subject { @remark }

    should_belong_to :profile, :blog_entry
    should_validate_presence_of :profile, :blog_entry, :content
  end
end
