Dir.glob(File.join( RAILS_ROOT, 'db', 'seeds', '**', '*.rb')).sort.each { | rb | load rb }

Project.new(:title=>"original project inc",:slug=>"original-projects-inc",:short_description=>"original-projects-inc",:projectcategory_id=>1).save