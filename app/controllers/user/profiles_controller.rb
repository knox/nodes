class User::ProfilesController < ApplicationController
  before_filter :login_required, :only =>  [ :show, :edit, :update, :destroy ]
	before_filter :login_prohibited, :only => [:new, :create]
   
  # This show action only allows users to view their own profile
  def show
    @user = current_user
  end  

  # render new.rhtml
  def new
    @user = User.new(:invitation_token => params[:invitation_token])
  end
 
  def create
    logout_keeping_session!
    @user = User.new(:login => params[:user][:login],
										 		 :email => params[:user][:email],
										 		 :name => params[:user][:name],
										 		 :password => params[:user][:password],
										 		 :password_confirmation => params[:user][:password_confirmation])
    success = @user && @user.save
    if success && @user.errors.empty?
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up! "
			flash[:notice] += "We're sending you 														an email with your activation code."
    else
      flash.now[:error]  = "We couldn't set up that account, sorry.  Please try again, or %s."
			flash[:error_item] = ["contact us", contact_site]
      render :action => 'new'
    end
  end

	def edit
		@user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(:name  => params[:user][:name],
															 :email => params[:user][:email])
      flash[:notice] = "Profile updated."
      redirect_to :action => 'show'
    else
			flash.now[:error] = "There was a problem updating your profile."
      render :action => 'edit'
    end
  end

  def destroy
    @user = current_user
    logout_killing_session!
    @user.destroy  
    flash[:notice] = "Your account has been deleted."
    redirect_to root_path
  end
  
end
