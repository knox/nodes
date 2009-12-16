class SubnetsController < ApplicationController

  before_filter :login_required, :only => [:new, :edit, :update, :create, :destroy]
  before_filter :find_subnet, :only => [:show, :edit, :update, :destroy] 

  require_role "admin", :for => [:edit, :update, :destroy], :unless => "current_user.owns_subnet?(params[:id].to_i)"

  def index
    @subnets = Subnet.all

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
    @subnet.destroy

    respond_to do |format|
      format.html { redirect_to(subnets_url) }
      format.xml  { head :ok }
    end
  end

  private
    def find_subnet
      @subnet = Subnet.find(params[:id])
    end
  

end
