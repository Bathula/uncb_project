require File.join( RAILS_ROOT, 'lib', 'legacy', 'yamldb.rb' )

puts "Seeding raw legacy data..."

YamlDb.load( File.join( RAILS_ROOT, 'db/migrate/data/legacy_data.yml' ) )
puts "Updating default value for SERVICE CATEGORIES and PROJECT CATEGORIES"

############




###########

puts "Updating default value for SERVICE CATEGORIES"
#### Creating default categories for services######
#Category.create(:name=>'Accounting & Finance',:description=>'Accounting & Finance')
#Category.create(:name=>'Admin / Office',:description=>'Admin / Office')
#Category.create(:name=>'Advertising / Marketing / PR',:description=>'Advertising / Marketing / PR')
#Category.create(:name=>'Architecture / Engineering',:description=>'Architecture / Engineering')
#Category.create(:name=>'Art / Illustration',:description=>'Art / Illustration')
#Category.create(:name=>'Automotive',:description=>'Automotive')
#Category.create(:name=>'Business / Mgmt',:description=>'Business / Mgmt')
#Category.create(:name=>'Craft / Skilled Trade',:description=>'Craft / Skilled Trade')
#Category.create(:name=>'Customer Service',:description=>'Customer Service')
#Category.create(:name=>'Education',:description=>'Education')
#Category.create(:name=>'Engineering',:description=>'Engineering')
#Category.create(:name=>'Farming / Gardening',:description=>'Farming / Gardening')
#Category.create(:name=>'Food & Bev / Hosp',:description=>'Food & Bev / Hosp')
#Category.create(:name=>'Film & Video',:description=>'Film & Video')
#Category.create(:name=>'Fundraising / Investment',:description=>'Fundraising / Investment')
#Category.create(:name=>'General Labor',:description=>'General Labor')
#Category.create(:name=>'Govt',:description=>'Govt')
#Category.create(:name=>'Design / Graphics',:description=>'Design / Graphics')
#Category.create(:name=>'Health / Medical',:description=>'Health / Medical')
#Category.create(:name=>'Human Resources',:description=>'Human Resources')
#Category.create(:name=>'Manufacturing',:description=>'Manufacturing')
#Category.create(:name=>'Nonprofit Industry',:description=>'Nonprofit Industry')
#Category.create(:name=>'Operations',:description=>'Operations')
#Category.create(:name=>'Product Design',:description=>'Product Design')
#Category.create(:name=>'Project Mgmt',:description=>'Project Mgmt')
#Category.create(:name=>'Real Estate / Construction',:description=>'Real Estate / Construction')
#Category.create(:name=>'Retail / Wholesale',:description=>'Retail / Wholesale')
#Category.create(:name=>'Sales / Biz Dev',:description=>'Sales / Biz Dev')
#Category.create(:name=>'Science / Biotech',:description=>'Science / Biotech')
#Category.create(:name=>'Software Dev',:description=>'Software Dev')
#Category.create(:name=>'Tech Support',:description=>'Tech Support')
#Category.create(:name=>'Transport / Travel',:description=>'Transport / Travel')
#Category.create(:name=>'Web Dev / Info Design',:description=>'Web Dev / Info Design')
#Category.create(:name=>'Writing / Editing',:description=>'Writing / Editing')
#Category.create(:name=>'Other',:description=>'Other')

########### Project categories############

@profiles=Profile.all
@profiles.each do |p|
MessageSetting.create(:profile_id => p.id,:messages_sent=> true)
end
