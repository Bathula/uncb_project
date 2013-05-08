require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  context "A Message" do
    should_belong_to :to, :from
    should_validate_presence_of :to, :from, :subject, :body

    context "with one receiver" do
      setup do
        @message = Message.make(:to => Profile.make)
      end

      should_change("# of messages", :by => 1) { Message.count }
    end

    context "with multiple receivers" do
      setup do
        @message = Message.make(:to => (1..3).map { Profile.make })
      end

      should_change("# of messages", :by => 3) { Message.count }
    end
  end
end
