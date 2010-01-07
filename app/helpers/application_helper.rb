# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def if_admin?
    yield if logged_in? && current_user.has_role?('admin')
  end

end
