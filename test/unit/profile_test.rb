require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ProfileTest < ActiveSupport::TestCase
  
  context "A Profile" do
    should_have_many :links
    should_have_many :originated_projects
    should_have_many :followed_projects
    should_have_many :member_projects
    should_have_many :membership_requests
    should_have_many :likes

    should_validate_presence_of :username, :city

    setup do
      @project = Project.make
      @profile = Profile.make
    end

    subject { @profile }      

    should "be able to follow a project" do
      assert_difference('@profile.followed_projects.count', 1) do
        @profile.follow_project(@project)
      end
    end

    should "be able to join an open project" do
      assert_difference('@profile.member_projects.count', 1) do
        @profile.join_project(@project)
      end
    end

    should "not be able to join a closed project" do
      @project.update_attribute(:membership_status, "closed")
      assert_difference('@profile.member_projects.count', 0) do
        @profile.join_project(@project)
      end
    end

    context "indicating requested membership in a project" do
      should "be false with no request" do
        assert !@profile.requested_membership?(@project)
      end

      should "be true with a request" do
        @project.update_attribute(:membership_status, "invite")
        MembershipRequest.create(:project => @project, :profile => @profile)
        assert @profile.requested_membership?(@project)
      end

      should "be false with a request to another project" do
        MembershipRequest.make(:profile => @profile)
        assert !@profile.requested_membership?(@project)
      end
    end
  end
  
  context "registration" do
    setup do
      @plan = Profile.plan
      @invite = Invite.make
    end
    
    should 'be registered with a valid invite token' do
      profile = Profile.register(@plan, @invite.token)      
      assert profile.valid?
      assert !profile.new_record?
      @invite.reload
      assert @invite.accepted?
    end
    
    should 'not be registered with an invalid invite code' do
      profile = Profile.register(@plan, @invite.token + "bad")      
      assert profile.errors[:invite_token].present?
      assert profile.new_record?      
    end
    
    should 'not spend an invite code if profile is invalid' do
      profile = Profile.register({}, @invite.token)
      @invite.reload
      assert !@invite.accepted?
    end
  end
  
  test 'automatically follow Original Projects' do
    project = Project.make(:slug => 'original-projects-inc')
    profile = Profile.make
    
    assert profile.is_following?(project)
  end

  test 'create a Profile' do
    assert Profile.make_unsaved.save
  end

  test 'tos_accepted is required on create' do
    profile = Profile.make_unsaved

    [nil, '', '0'].each do |val|
      profile.tos_accepted = val
      assert !profile.save
      assert profile.errors[:base] =~ /must be accepted/i
    end

    profile.tos_accepted = '1'
    assert profile.save
  end

  test 'user password can be checked' do
    username = 'nathan'
    password = 'zaq1xsw2'
    profile = Profile.make(:username => username, :password => password)
    assert profile.valid_password?(password)
  end

  test "location should be formatted correctly" do
    assert_equal "Durham", Profile.new(:city => 'Durham').location
    assert_equal "NC", Profile.new(:state => 'NC').location
    assert_equal "Durham, NC", Profile.new(:city => 'Durham', :state => 'NC').location
    assert_equal "Durham, NC 27701", Profile.new(:city => 'Durham', :state => 'NC', :zip => '27701').location
  end
end
