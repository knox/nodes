class PeopleController < ApplicationController
  
  after_filter :store_location

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
      format.xml { render :xml => People.all(:conditions => ['activated_at IS NOT NULL'], :order => 'name') }
    end
	end

	def show
		@user = User.find_by_login(params[:id])
    if @user
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @user }
      end
    else
      render :file => "#{RAILS_ROOT}/public/404.html", :layout => false, :status => 404
    end
	end

  private
    def load_sorted_page
      sort_init 'login'
      sort_update
      @users = User.paginate(:page => params[:page],
        :conditions => ['activated_at IS NOT NULL'],
        :order => sort_clause
      )
    end
end
