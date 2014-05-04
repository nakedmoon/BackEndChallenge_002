class Game < ActiveRecord::Base

  attr_accessor :current_session

  serialize :moves, Hash

  MOVES_COUNT = 10 # set here game moves count
  MOVES_ATTRIBUTES = (1..MOVES_COUNT).map{|move| "move_#{"%02d" % move}".to_sym}
  MOVE_RESULTS_CLASSES = {'W' => 'success', 'X' => 'info', 'L' => 'danger'}
  MOVE_RESULTS_LABELS = {'W' => 'win', 'X' => 'draw', 'L' => 'loose'}


  WEAPONS = ['rock', 'paper', 'scissor', 'lizard', 'spock']

  # the weapon indexed at 0 have the rule indexed at 0 : ROCK has the rule XLWWL
  # it means that the weapon ROCK wins over the weapon indexed at 2 : ..W..
  RULES = ['XLWWL', 'WXLLW', 'LWXWL', 'LWLXW', 'WLWLX']


  # generate unique game uid after create
  before_save(on: :create) do
    self.uid = SecureRandom.hex(10)
  end

  validate :check_players, :on => :update
  validates_presence_of :current_session, :on => :update

  # you submit your moves, if both palyers joined the game
  def check_players
    errors[:base] << "You aren't ready to fight!" unless ready_to_fight?
  end

  def finished?
    # the game is finished if moves hash both players submits our moves
    # compact array exclude nil values (player has just joined the game, but it not has moved)
    moves.values.compact.size == 2
  end

  def player_has_moved?(game_session = nil)
    !moves.fetch(game_session || current_session).nil? rescue false
  end


  def waiting_for_an_adversary?
    # the game wait for an adversary unless both players join the game
    players_count < 2
  end

  def ready_to_fight?
    # both players joined the game
    players_count == 2
  end

  def fight(selection)
    self.moves.store(current_session, selection)
  end

  def join
    # a session_id join the game
    # session_id become key of moves hash and initialized to nil
    # the key value will become an Hash with session_id moves
    if ready_to_fight?
      # raise exception if both players joined the game and a third session_id try to join
      raise StandardError, "This game session has already token!" unless player_has_joined?
    else
      self.update_column(:moves, moves.merge({current_session => nil}))
    end
  end

  def player_has_joined?(game_session = nil)
    # check if session_id has already joined the game
    sessions.include?(game_session || current_session)
  end

  # games sessions in this game
  def sessions
    moves.keys
  end

  # game sessions count
  def players_count
    sessions.size
  end

  # build result matrix
  def result
    result_matrix = []
    current_player_points = 0
    other_player_points = 0
    # fetch raise exception id key not found
    # this means that current session has not joined the game
    current_player_moves = moves.fetch(current_session)
    other_player_moves = moves.fetch(other_session)
    Game::MOVES_ATTRIBUTES.each do |move|
      current_move = current_player_moves.fetch(move)
      other_move = other_player_moves.fetch(move)
      move_result = Game.move_result(current_move, other_move)
      current_player_points += 1 if move_result == 'W'
      other_player_points +=1 if move_result == 'L'
      result_matrix << [current_move.to_i, other_move.to_i, move_result]
    end
    [result_matrix, current_player_points, other_player_points]
  end



  def other_session
    sessions.reject{|s| s==current_session}.first
  end

  def self.move_rule(move)
    RULES[move].chars
  end

  def self.move_result(move_1, move_2)
    # check both weapons and
    # return W (win), L (loose), X (tie)
    move_rule(move_1.to_i)[move_2.to_i]
  end






end

