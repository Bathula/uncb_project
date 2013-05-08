Sham.define do
  city          { Faker::Address.city             }
  country       { Faker::Address.uk_country       }
  email         { Faker::Internet.email           }
  first_name    { Faker::Name.first_name          }
  last_name     { Faker::Name.last_name           }
  name          { Faker::Name.name                }
  password      { Faker.bothify '########'        }
  phone         { Faker::PhoneNumber.phone_number }
  state         { Faker::Address.us_state         }
  username      { Faker::Internet.user_name       }
  word          { Faker::Lorem.words[0].first     }
  zipcode       { Faker::Address.zip_code         }
end

Profile.blueprint do
  active       { true       }

  username
  password     { 'testing'  }
  password_confirmation { password  }
  tos_accepted { '1' }

  display_name { Sham.name  }
  email
  first_name
  last_name

  city
  state
  country      { "United States" }

  phone_home   { Sham.phone }
  phone_mobile { Sham.phone }
  phone_office { Sham.phone }
end

Project.blueprint do
  active            { true }
  current_resources { Faker::Lorem.words[0, 20] }
  description       { Faker::Lorem.words[0, 20] }
  short_description { Faker::Lorem.words[0, 20] }
  membership_status { Project::MEMBERSHIP_STATUS_OPEN }
  public            { true }
  resources_needed  { Faker::Lorem.words[0, 20] }
  title             { Sham.word }
  slug              { title.downcase.gsub(/[^\w]+/, '-') }
end

Membership.blueprint do
  profile { Profile.make }
  project { Project.make }
end

Interest.blueprint do
  profile { Profile.make }
  project { Project.make }
end

MembershipRequest.blueprint do
  profile { Profile.make }
  project { Project.make(:membership_status => "invite") }
end

Comment.blueprint do
  profile { Profile.make }
  project { Project.make }
  content { "This is a great project." }
end

Reply.blueprint do
  profile { Profile.make }
  comment { Comment.make }
  content { "This is a great project." }
end

Like.blueprint do
  profile { Profile.make }
  project { Project.make }
end

Message.blueprint do
  to      { Profile.make }
  from    { Profile.make }
  subject { "Project Name" }
  body    { "Email content" }
end

InviteRequest.blueprint do
  name { Sham.name }
  email { Sham.email }
  city { Sham.city }
  state { Sham.state }
  country { Sham.country }
  project { false }
end

Invite.blueprint do
  invite_request { InviteRequest.make }
end

BlogEntry.blueprint do
  profile { Profile.make }
  project { Project.make }
  title   { "Status Update" }
  content { "The project is progressing." }
end

Remark.blueprint do
  profile { Profile.make }
  blog_entry { BlogEntry.make }
  content { "This is a great project." }
end
