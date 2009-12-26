class PeopleController < ApplicationController
  
  after_filter :store_location

  def index
    @users = User.list_of_active
	end

	def show
		@user = User.find_by_login(params[:id])
	end

end
