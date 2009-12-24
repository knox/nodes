class PeopleController < ApplicationController
  
  after_filter :store_location

  def index
    @users = User.find(:all,
        :conditions => ['enabled = ? and activated_at IS NOT NULL', true],
        :order => 'login'
    )
	end

	def show
		@user = User.find_by_login(params[:id])
	end

end
