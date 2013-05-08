require 'test_helper'

class ReplyTest < ActiveSupport::TestCase
  context "A Reply" do
    setup do
      @reply = Reply.make
    end

    subject { @reply }

    should_belong_to :profile, :comment
    should_validate_presence_of :profile, :comment, :content
  end
end
