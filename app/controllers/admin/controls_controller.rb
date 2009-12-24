class Admin::ControlsController < ApplicationController
  before_filter :login_required
	require_role :admin

  def index
    @users = User.count
	end
end
