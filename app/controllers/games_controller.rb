class GamesController < ApplicationController
  def new
  end

  def create
    score = Score.new(params[:score])
    score.save!
    render json: {status: true}
  end
end
