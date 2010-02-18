class SubnetsController < ApplicationController
  
  before_filter :login_required, :only => [:new, :edit, :update, :create, :destroy]
  before_filter :find_subnet, :only => [:show, :edit, :update, :destroy] 
  after_filter :store_location, :only => [:index, :show, :new, :edit]
  
  require_role "admin", :for => [:edit, :update, :destroy], :unless => "current_user.owns_subnet?(params[:id])"
  
  def index
    respond_to do |format|
      format.html { load_sorted_page }
      format.js { 
        load_sorted_page
        render :update do |page|
          page.replace_html  'table', :partial => 'table'
          page.replace_html  'pagination', :partial => 'pagination'
        end
      }
      format.xml { render :xml => Subnet.all(:order => 'name') }
    end
  end
  
  def show
    if @subnet
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @subnet }
      end
    else
      render :file => "#{RAILS_ROOT}/public/404.html", :layout => false, :status => 404
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
        flash[:success] = 'Subnet was successfully created.'
        format.html { redirect_to(@subnet) }
        format.xml  { render :xml => @subnet, :status => :created, :location => @subnet }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @subnet.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    if @subnet
      respond_to do |format|
        if @subnet.update_attributes(params[:subnet])
          flash[:success] = 'Subnet was successfully updated.'
          format.html { redirect_to(@subnet) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @subnet.errors, :status => :unprocessable_entity }
        end
      end
    else
      render :file => "#{RAILS_ROOT}/public/404.html", :layout => false, :status => 404
    end
  end
  
  def destroy
    if @subnet
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
    else
      render :file => "#{RAILS_ROOT}/public/404.html", :layout => false, :status => 404
    end
  end
  
  def suggest_ip
    respond_to do |format|
      format.js { 
        addr = Subnet.suggest_addr
        render :update do |page|
          page.assign "document.getElementById('subnet_ip_address').value", addr.to_s
          page.assign "document.getElementById('subnet_prefix_length').value", addr.prefix_len
        end
      }
    end
  end
  
  private
  def find_subnet
    @subnet = Subnet.find_by_name(params[:id])
  end
  
  def load_sorted_page
    sort_init 'name'
    sort_update
    @subnets = Subnet.paginate(:page => params[:page], :include => :owner, :order => sort_clause) 
  end
  
end
