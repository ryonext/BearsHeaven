class WelcomeController < ApplicationController
  def index
    redirect_to new_game_path
  end
end
