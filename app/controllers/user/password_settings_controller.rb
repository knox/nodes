class User::PasswordSettingsController < ApplicationController
	before_filter :login_required

  # Change password view
  def index
  end
  
  # Change password action  
  def create
		if current_user.change_password!(params[:old_password], params[:password], params[:password_confirmation])
   		flash[:success] = 'Password successfully updated.'
    	redirect_to user_profile_path(current_user)		
		else
			@old_password = nil
      flash.now[:error] = current_user.errors.on_base || 'There was a problem updating your password.'
      render :action => 'index'
		end
	end

end
