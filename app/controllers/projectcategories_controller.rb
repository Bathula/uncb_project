class ProjectcategoriesController < Admin::ProjectcategoriesController
  # GET /projectcategories
  # GET /projectcategories.xml
  def index
    @projectcategories = Projectcategory.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @projectcategories }
    end
  end

  # GET /projectcategories/1
  # GET /projectcategories/1.xml
  def show
    @projectcategory = Projectcategory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @projectcategory }
    end
  end

  # GET /projectcategories/new
  # GET /projectcategories/new.xml
  def new
    @projectcategory = Projectcategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @projectcategory }
    end
  end

  # GET /projectcategories/1/edit
  def edit
    @projectcategory = Projectcategory.find(params[:id])
  end

  # POST /projectcategories
  # POST /projectcategories.xml
  def create
    @projectcategory = Projectcategory.new(params[:projectcategory])

    respond_to do |format|
      if @projectcategory.save
        flash[:notice] = 'Projectcategory was successfully created.'
        format.html { redirect_to(@projectcategory) }
        format.xml  { render :xml => @projectcategory, :status => :created, :location => @projectcategory }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @projectcategory.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /projectcategories/1
  # PUT /projectcategories/1.xml
  def update
    @projectcategory = Projectcategory.find(params[:id])

    respond_to do |format|
      if @projectcategory.update_attributes(params[:projectcategory])
        flash[:notice] = 'Projectcategory was successfully updated.'
        format.html { redirect_to(@projectcategory) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @projectcategory.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /projectcategories/1
  # DELETE /projectcategories/1.xml
  def destroy
    @projectcategory = Projectcategory.find(params[:id])
    @projectcategory.destroy

    respond_to do |format|
      format.html { redirect_to(projectcategories_url) }
      format.xml  { head :ok }
    end
  end
end
