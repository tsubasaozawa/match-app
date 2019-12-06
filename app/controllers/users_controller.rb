class UsersController < ApplicationController
  before_action :set_user, only: [:show]

  def index
    @users = User.all
    @matched_users = current_user.matchers
  end

  def show
    @relationship = Relationship.new
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
