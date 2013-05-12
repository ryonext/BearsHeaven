class GamesController < ApplicationController
  def new
    render :layout => false
  end

  def create
    score = Score.new(params[:score])
    score.save!
    render json: {status: true}
  end

  def index
    @scores = Score.order("point desc").limit(10)
  end
end
