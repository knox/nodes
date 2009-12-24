# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation, :old_password

  include AuthenticatedSystem
  include RoleRequirementSystem

  # Change to the location of your contact form
  def contact_site
    root_path
  end

end
