class Admin::UsersController < ApplicationController
	before_filter :login_required
	require_role :admin

  def index
    @users = User.paginate(:page => params[:page], :order => 'login')
  end

	# Administrative activate action
	def update
		@user = User.find_by_login(params[:id])
    if @user.activate!
      flash[:success] = 'User %s activated.'
      flash[:success_item] = [ "#{@user.login}", user_profile_path(@user) ]
    else
      flash[:error] = 'There was a problem activating the user %s.'
      flash[:error_item] = [ "#{@user.login}", user_profile_path(@user) ]
    end
    redirect_to :action => 'index'		
	end

  def destroy
    @user = User.find_by_login(params[:id])
    @user.destroy
    redirect_to :action => 'index'    
  end
  
end

