class NodesController < ApplicationController

  map_layer :node, :text => :map_popup_text

  before_filter :find_node, :only => [:show, :edit, :update, :destroy] 
  before_filter :login_required, :only => [:new, :edit, :update, :create, :destroy]
  after_filter :store_location, :only => [:index, :show, :new, :edit]

  require_role "admin", :for => [:edit, :update, :destroy], :unless => "current_user.owns_node?(params[:id])"

  # GET /nodes
  # GET /nodes.xml
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
      format.xml  { render :xml => Node.all(:order => 'name') }
    end
  end

  # GET /nodes/1
  # GET /nodes/1.xml
  def show
    if @node
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @node }
      end
    else
      render :file => "#{RAILS_ROOT}/public/404.html", :layout => false, :status => 404
    end
  end

  # GET /nodes/new
  # GET /nodes/new.xml
  def new
    @node = Node.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @node }
    end
  end

  # GET /nodes/1/edit
  def edit
    render :file => "#{RAILS_ROOT}/public/404.html", :layout => false, :status => 404 unless @node
  end

  # POST /nodes
  # POST /nodes.xml
  def create
    @node = Node.new(params[:node])

    respond_to do |format|
      if @node.save
        flash[:success] = 'Node was successfully created.'
        format.html { redirect_to(@node) }
        format.xml  { render :xml => @node, :status => :created, :location => @node }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @node.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /nodes/1
  # PUT /nodes/1.xml
  def update
    if @node
      respond_to do |format|
        if @node.update_attributes(params[:node])
          flash[:success] = 'Node was successfully updated.'
          format.html { redirect_to(@node) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @node.errors, :status => :unprocessable_entity }
        end
      end
    else
      render :file => "#{RAILS_ROOT}/public/404.html", :layout => false, :status => 404
    end
  end

  # DELETE /nodes/1
  # DELETE /nodes/1.xml
  def destroy
    if @node
      @node.destroy
      respond_to do |format|
        format.html { redirect_to(nodes_path) }
        format.xml  { head :ok }
      end
    else
      render :file => "#{RAILS_ROOT}/public/404.html", :layout => false, :status => 404
    end
  end

  def map_popup_text
    "#{self.name}"   
  end

  def lookup
    require 'ipaddr'
    ipaddr = IPAddr.new(params[:ip_address])
    @node = Node.find_by_ip(ipaddr.to_i, :select => :name)
    if @node
      redirect_to node_path(@node)
    else
      render :file => "#{RAILS_ROOT}/public/404.html", :layout => false, :status => 404
    end
  end
  
  private
    def find_node
      @node = Node.find_by_name(params[:id])
    end
  
    def load_sorted_page
      sort_init 'name'
      sort_update
      @nodes = Node.paginate(:page => params[:page], :include => [ :subnet, :owner ], :order => sort_clause)
  end
  
end
