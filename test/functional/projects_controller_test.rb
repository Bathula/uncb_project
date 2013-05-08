require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  test "actions protected from non-logged-in users" do
    assert_requires_login :new => :get, :create => :post
  end

  test "GET :new" do
    login
    get(:new)
    assert_response(:success)
    assert_template 'projects/new'
  end

  test "GET :my_projects" do
    login
    get(:my_projects)
    assert_response :success
    assert_template 'projects/my_projects'
  end

  test "POST :create" do
    profile = login
    assert_difference 'profile.projects.count' do
      post :create, :project => Project.plan
    end
    assert_redirected_to dashboard_path
  end

  # TODO: Determine if the index is necessary. Should it
  #   show all the projects for a person?
  test "GET :index" do
    project = Project.make
    login
    get :index
    assert_response :success
    assert_template 'projects/index'
  end

  test "GET :edit" do
    profile = login
    project = Project.make
    project.promote_profile_to_originator(profile)

    get(:edit, :id => project.id)
    assert_response(:success)
    assert_template('projects/edit')
  end

  test "POST :update" do
    profile = login
    project = Project.make
    project.promote_profile_to_originator(profile)

    newproject = project.attributes.merge( 'title' => 'New Title')
    post(:update, :id => project.id, :project => newproject)
    assert_equal "New Title", Project.find(project.id).title
    assert_redirected_to dashboard_path
  end

  test "POST :update with bad data" do
    profile = login
    project = Project.make
    project.promote_profile_to_originator(profile)

    newproject = project.attributes.merge( 'title' => '')
    post(:update, :id => project.id, :project => newproject)
    assert_response(:success)
    assert_template('projects/edit')
  end

  test "GET /project/project-name-slug" do
    login
    slug = 'this-is-a-banana-slug'
    project = Project.make( :slug => slug )

    get :show, :id => slug
    assert_response( :success )
    assert_template('projects/show')
  end

  test "GET /project/project-name-slug for private project" do
    login
    slug = 'this-is-a-banana-slug'
    project = Project.make(:slug => slug, :public => false)

    get :show, :id => slug
    assert_response(401)
  end

  test "GET :slug_check" do
    login
    project = Project.make(:slug => 'this-is-a-test')

    get :slug_check, :title => 'This is a test'
    assert_response(:success)
    assert_equal({'unique' => false, 'slug' => 'this-is-a-test'}, JSON.parse(@response.body))

    get :slug_check, :title => 'This should be unique'
    assert_response(:success)
    assert_equal({'unique' => true, 'slug' => 'this-should-be-unique'}, JSON.parse(@response.body))
  end

end
