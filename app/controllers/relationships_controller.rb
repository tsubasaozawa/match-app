class RelationshipsController < ApplicationController
  def create
    current_user.active_relationships.create(create_params)
  end

  private

  def create_params
    params.permit(:following_id)
  end
end
