class Admin::StatesController < ApplicationController
	before_filter :login_required
	require_role :admin

  def update
    @user = User.find_by_login(params[:id])
    if @user.update_attribute(:enabled, true)
      flash[:success] = 'User %s enabled.'
      flash[:success_item] = [ "#{@user.login}", user_profile_path(@user) ]
    else
      flash[:error] = 'There was a problem enabling the user %s.'
      flash[:error_item] = [ "#{@user.login}", user_profile_path(@user) ]
    end
    redirect_to admin_users_path
  end

  def destroy
    @user = User.find_by_login(params[:id])
    if @user.update_attribute(:enabled, false)
      flash[:success] = 'User %s disabled.'
      flash[:success_item] = [ "#{@user.login}", user_profile_path(@user) ]
    else
      flash[:error] = 'There was a problem disabling the user %s.'
      flash[:error_item] = [ "#{@user.login}", user_profile_path(@user) ]
    end
    redirect_to admin_users_path
  end

end
