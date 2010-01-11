# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController

  before_filter :login_required, :only => :destroy
  before_filter :login_prohibited, :only => [:new, :create]
  
  # render new.rhtml
  def new
  end

  def create
    logout_keeping_session!
		password_authentication(params[:login], params[:password])
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

  protected
  
  def password_authentication(login, password)
    User.authenticate(login, password) do |user, message, item_msg, item_path|
			(successful_login(user) and return) if user
			(flash[:error_item] = [item_msg, send(item_path)]) if item_path
			failed_login(message)
		end
  end
  
  private

  def successful_login(user)
    # Protects against session fixation attacks, causes request forgery
    # protection if user resubmits an earlier form using back
    # button. Uncomment if you understand the tradeoffs.
		#
		# reset_session has been uncommented in the restful_authentication_tutorial app,
		# which is not the default setting of the restful_authentication plugin
		# guides.rails.info/securing_rails_applications/security.html#_session_fixation_countermeasures
		#
		refered_from = session[:refered_from]
		return_to = session[:return_to]
    reset_session
		session[:refered_from] = refered_from 
		session[:return_to] = return_to
    self.current_user = user
    new_cookie_flag = (params[:remember_me] == "1")
    handle_remember_cookie! new_cookie_flag
    flash[:notice] = "Logged in successfully."
    redirect_to people_path(user)
  end

  def failed_login(message)
    @login             = params[:login]
    @remember_me       = params[:remember_me]
    flash.now[:error] = message
    render :action => 'new'
  end

end
