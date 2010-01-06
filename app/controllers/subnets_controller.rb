class SubnetsController < ApplicationController

  before_filter :login_required, :only => [:new, :edit, :update, :create, :destroy]
  before_filter :find_subnet, :only => [:show, :edit, :update, :destroy] 
  after_filter :store_location, :only => [:index, :show, :new, :edit]

  require_role "admin", :for => [:edit, :update, :destroy], :unless => "current_user.owns_subnet?(params[:id])"

  def index
    @subnets = Subnet.all(:order => 'name')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @subnets }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @subnet }
    end
  end

  def new
    @subnet = Subnet.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @subnet }
    end
  end

  def edit
  end

  def create
    @subnet = Subnet.new(params[:subnet])

    respond_to do |format|
      if @subnet.save
        flash[:notice] = 'Subnet was successfully created.'
        format.html { redirect_to(@subnet) }
        format.xml  { render :xml => @subnet, :status => :created, :location => @subnet }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @subnet.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @subnet.update_attributes(params[:subnet])
        flash[:notice] = 'Subnet was successfully updated.'
        format.html { redirect_to(@subnet) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @subnet.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    if @subnet.has_foreign_nodes? and !current_user.has_role?('admin')
        flash[:warning] = 'Cannot destroy Subnet: it has foreign nodes within.'
        respond_to do |format|
          format.html { redirect_back_or_default(@subnet) }
          format.xml  { render :xml => flash[:warning], :status => :unprocessable_entity }
        end
    else
      @subnet.destroy
      respond_to do |format|
        format.html { redirect_to(subnets_url) }
        format.xml  { head :ok }
      end
    end
  end

  private
    def find_subnet
      @subnet = Subnet.find_by_name(params[:id])
    end
  

end
