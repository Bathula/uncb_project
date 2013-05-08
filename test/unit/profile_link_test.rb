require 'test_helper'

class ProfileLinkTest < ActiveSupport::TestCase
  context "A ProfileLink" do
    should_belong_to :profile
    should_validate_presence_of :url
  end
end
