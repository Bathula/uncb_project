class RatingsController < ApplicationController

before_filter :require_profile
skip_before_filter :auth, :only => :get_avaerage_rating


def rate
    @asset = Project.find(params[:project_id])
    #@asset = Project.find(23)
		rating = Rating.first(:conditions => ["rateable_type=?", 'Project'])

		if @asset.rated_by?(current_profile.id)
    	UserRating.delete_all(["rating_id = ? AND user_id = ?",rating.id, current_profile.id])
		end
    puts "fdsfdsds"
p params[:star1]
p current_profile.user_is_pro?
puts "fdsfdsds"
    @asset.rate_it(params[:star1], current_profile,current_profile.user_is_pro?)


	@asset.update_ratings_cache

		# Data should all come from the Project Model Cache
		count = @asset.rating_count_cache
		count_pro = @asset.rating_count_cache_pro
		average_pro = @asset.rating_cache_pro
		average	= @asset.rating_cache
		#@asset.rating_cache = average
		#@asset.rating_cache_pro = average_pro
		#@asset.rating_count_cache = count
		#@asset.rating_count_cache_pro = count_pro
		#@asset.save

		message = 'MESSAGE'
		user_rating = @asset.rating_by(current_profile)

		j = {"count" => count, "average" => average, "user_rating" => user_rating, "average_pro" => average_pro, "count_pro" => count_pro, "message" => message}
		render :json => j
  end

	def get_ratings_count
		@p= Project.find(params[:project_id])
		j = @p.ratings_count
		render :json => j
	end

	def get_average_rating
		@p= Project.find(params[:project_id])
		j = @p.average_rating
		render :json => j
	end

	def get_ratings_count_pro
		@p= Project.find(params[:project_id])
		j = @p.ratings_count_pro
		render :json => j
	end

	def get_average_rating_pro
		@p= Project.find(params[:project_id])
		j = @p.average_rating_pro
		render :json => j
	end



  

end
