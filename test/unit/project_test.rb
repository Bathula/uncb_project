require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ProjectTest < ActiveSupport::TestCase
  context "A Project" do
    setup do
      @project = Project.make_unsaved(:title => "An American Title", :slug => nil)
    end

    subject { @project }

    should_validate_presence_of :title, :description
    should_have_many :originators, :members, :followers, :membership_requests, :comments,
      :likes, :blog_entries

    should "add slug if it does not exist before validation on create" do
      @project.valid?
      assert_equal "an-american-title", @project.slug
    end

    should "have open membership by default" do
      assert @project.has_open_membership?
    end

    should "have list non-member followers" do
      @project.save
      member    = Profile.make
      follower  = Profile.make

      Membership.create(:project => @project, :profile => member)
      Interest.create(:project => @project, :profile => follower)

      assert_equal [member, follower], @project.followers
      assert_equal [follower], @project.non_member_followers
    end

    context "finding comments from originators" do
      setup do
        @originator = Profile.make
        @project.save
        @project.promote_profile_to_originator(@originator)
        @comment = Comment.make(:project => @project, :profile => @originator)
      end

      should "not include comments from originators of other projects" do
        other = Comment.make
        other.project.promote_profile_to_originator(other.profile)
        assert_equal [@comment], @project.comments.by_originators
      end

      should "not include comments from non-members" do
        Comment.make(:project => @project)
        assert_equal [@comment], @project.comments.by_originators
      end

      should "not include comments from non-originating members" do
        member = Profile.make
        @project.add_participant(member)
        Comment.make(:project => @project, :profile => member)
        assert_equal [@comment], @project.comments.by_originators
      end
    end
  end
end
