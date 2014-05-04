require 'spec_helper'

describe Game do


  it "join game" do
    game = Fabricate(:game)
    expect(game.uid).not_to be_nil
    game.current_session = 'fe851395e29093ecddeb06d3b5490ca0'
    expect(game.waiting_for_an_adversary?).to be true
    game.join
    expect(game.sessions.count).to be 1
    expect(game.player_has_joined?).to be true
    expect(game.moves.fetch('fe851395e29093ecddeb06d3b5490ca0')).to be_nil # initialize moves for current_session
    game.current_session = '310cfde009c74d858a83304caf9a4579'
    game.join
    expect(game.sessions.count).to be 2
    expect(game.player_has_joined?).to be true
    expect(game.moves.fetch('310cfde009c74d858a83304caf9a4579')).to be_nil # initialize moves for current_session
    expect(game.ready_to_fight?).to be true
  end

  it "unable to join a ready to fight game" do
    game = Fabricate(:game)
    game.current_session = 'fe851395e29093ecddeb06d3b5490ca0'
    game.join
    game.current_session = '310cfde009c74d858a83304caf9a4579'
    game.join
    game.current_session = 'fakesession'
    expect{game.join}.to raise_error(StandardError)

  end

  it "fight game" do
    game = Fabricate(:game)
    game.current_session = 'fe851395e29093ecddeb06d3b5490ca0'
    game.join
    game.current_session = '310cfde009c74d858a83304caf9a4579'
    game.join
    expect(game.ready_to_fight?).to be true
    # select scissor
    selection = {:move_01 =>"2",
                 :move_02 =>"0",
                 :move_03 =>"0",
                 :move_04 =>"0",
                 :move_05 =>"0",
                 :move_06 =>"0",
                 :move_07 =>"0",
                 :move_08 =>"0",
                 :move_09 =>"0",
                 :move_10 =>"0"}
    game.fight(selection)
    # select lizzard
    game.current_session = 'fe851395e29093ecddeb06d3b5490ca0'
    selection = {:move_01 =>"3",
                 :move_02 =>"0",
                 :move_03 =>"0",
                 :move_04 =>"0",
                 :move_05 =>"0",
                 :move_06 =>"0",
                 :move_07 =>"0",
                 :move_08 =>"0",
                 :move_09 =>"0",
                 :move_10 =>"0"}
    game.fight(selection)
    game_result = game.result
    expect(game.result[1]).to be 0 # points of lizard move
    expect(game.result[2]).to be 1 # points of scissor move




  end






end
