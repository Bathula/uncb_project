class CategoriesController < Admin::CategoriesController
  def show
    @category = Category.find(params[:id])
  end

end
