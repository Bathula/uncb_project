require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  context "A Comment" do
    setup do
      @comment = Comment.make
    end

    subject { @comment }

    should_belong_to :profile, :project
    should_have_many :replies
    should_validate_presence_of :profile, :project, :content
  end
end
