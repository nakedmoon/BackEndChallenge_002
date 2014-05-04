class GamesController < ApplicationController
  before_action :set_game_session, :set_game, only: [:show, :play, :fight, :result, :ready_to_fight, :finished]
  before_action :set_game_session, :only => [:index]

  include ActionController::Live


  # GET /games
  # GET /games.json
  def index
    @games = Game.all.find_all{|g| g.waiting_for_an_adversary?}
  end

  # GET /games/1
  # GET /games/1.json
  def show
    render :text => "You haven't joined ths game!" unless @game.player_has_moved?
  end


  # GET /games/1/challenger
  def play
    begin
      @game.join
      $redis.publish("game.#{@game.id}.join", true) if @game.ready_to_fight?
    rescue StandardError => play_error
      #redirect_to games_path, alert: play_error.message
      render :text => play_error.message, status: 404
    end
  end

  def result
    render :partial => 'result', :locals => {game: @game}
  end

  def generate
    @game = Game.new
    if @game.save
      redirect_to play_game_path(@game)
    else
      redirect_to games_path, alert: "Game generation error #{@game.errors.full_messages}"
    end
  end

  def finished
    begin
      response.headers['Content-Type'] = 'text/event-stream'
      redis = Redis.new
      redis.subscribe("game.#{@game.id}.finished") do |on|
        on.message do |event, data|
          response.stream.write("event: update\n")
          response.stream.write("data: #{data }\n\n")
        end
      end
      render nothing: true

    rescue IOError
      logger.info "Stream closed"
    ensure
      redis.quit
      response.stream.close
    end
  end


  def ready_to_fight
    begin
      response.headers['Content-Type'] = 'text/event-stream'
      redis = Redis.new
      redis.subscribe("game.#{@game.id}.join") do |on|
        on.message do |event, data|
          response.stream.write("event: update\n")
          response.stream.write("data: #{data }\n\n")
        end
      end
      render nothing: true

    rescue IOError
      logger.info "Stream closed"
    ensure
      redis.quit
      response.stream.close
    end
  end




  def fight
    respond_to do |format|
      @game.fight(game_params[:moves])
      if @game.save
        $redis.publish("game.#{@game.id}.finished", true) if @game.finished?
        format.html { redirect_to @game }
      else
        format.html {
          flash[:alert] = @game.errors.full_messages.first
          render :play
        }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
      @game.current_session = session[:game_session]
    end

    def set_game_session
      session[:game_session] ||= session.id
    end



    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:moves => [Game::MOVES_ATTRIBUTES])
    end



end
