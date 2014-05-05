require 'spec_helper'

describe "games/play" do
  before(:each) do

  end


  it "test match"  do
    # set session of first player
    page.set_rack_session("game_session" => 'fe851395e29093ecddeb06d3b5490ca0')



    # First player has joined, generating new game
    # Checking message and disabled controls
    visit generate_game_path
    expect(page.find_by_id('message')).to have_content('Waiting for an adversary.....')
    expect(find_button('Fight')[:class].include?('btn btn-danger disabled')).to be_true
    Game::MOVES_ATTRIBUTES.each do |move|
      select = page.find_by_id("game_moves_#{move}")
      expect(select.disabled?).to eq('disabled')
    end

    # Saving current play path
    game_play_url = current_path

    # Same player (session) return to just generated game
    # Checking message and disabled controls
    visit game_play_url
    message = page.find_by_id('message')
    expect(message[:class].include?('alert fade in alert-warning')).to be_true
    expect(message).to have_content('Waiting for an adversary.....')
    expect(find_button('Fight')[:class].include?('btn btn-danger disabled')).to be_true
    Game::MOVES_ATTRIBUTES.each do |move|
      select = page.find_by_id("game_moves_#{move}")
      expect(select.disabled?).to eq('disabled')
    end

    # change session, simulate second player (in an other browser session)
    page.set_rack_session("game_session" => '310cfde009c74d858a83304caf9a4579')

    # Second player (session) play the game
    # Checking message and enabled controls
    visit game_play_url
    message = page.find_by_id('message')
    expect(message).to have_content('Ready to fight!')
    expect(message[:class].include?('alert fade in alert-info')).to be_true
    expect(find_button('Fight')[:class].include?('btn btn-success')).to be_true
    Game::MOVES_ATTRIBUTES.each do |move|
      select = page.find_by_id("game_moves_#{move}")
      expect(select.disabled?).to eq(nil)
    end

    # change session, simulate third player (in an other browser session)
    page.set_rack_session("game_session" => 'differentsession')
    visit game_play_url
    # Checking the game is already been token
    expect(page.status_code).to eq(404)
    expect(page.body).to eq('This game session has already token!')

    # set session of first player
    page.set_rack_session("game_session" => 'fe851395e29093ecddeb06d3b5490ca0')
    # First player reload page
    # Checking message and enabled controls
    visit game_play_url
    message = page.find_by_id('message')
    expect(message).to have_content('Ready to fight!')
    expect(message[:class].include?('alert fade in alert-info')).to be_true
    fight_button = find_button('Fight')
    expect(fight_button[:class].include?('btn btn-success')).to be_true
    Game::MOVES_ATTRIBUTES.each do |move|
      select = page.find_by_id("game_moves_#{move}")
      expect(select.disabled?).to eq(nil)
    end

    # First player submit fight form
    move = page.find_by_id("game_moves_move_01")
    move.select('scissor')
    expect(move.value).to eq('2')
    fight_button.click
    # Redirect to show page
    show_message = page.find_by_id('message')
    expect(show_message).to have_content('Waiting for finish.....')
    expect(show_message[:class].include?('alert fade in alert-warning')).to be_true

    # save game info url
    game_info_url = current_path

    # Second player submit fight form
    page.set_rack_session("game_session" => '310cfde009c74d858a83304caf9a4579')
    visit game_play_url
    fight_button = find_button('Fight')
    move = page.find_by_id("game_moves_move_01")
    move.select('lizard')
    expect(move.value).to eq('3')
    fight_button.click

    # Redirect to show page
    show_message = page.find_by_id('message')
    expect(show_message).to have_content('Finished!')
    expect(show_message[:class].include?('alert fade in alert-info')).to be_true
    # Check result: lizard loose over scissor, player 2 loose
    game_summary = page.find_by_id('game_summary')
    expect(game_summary).to have_content('Summary: 0 - 1 You loose!')
    expect(game_summary[:class].include?('danger')).to be_true


    # First player update game info page
    # Check if finished and result
    page.set_rack_session("game_session" => 'fe851395e29093ecddeb06d3b5490ca0')
    visit game_info_url
    show_message = page.find_by_id('message')
    expect(show_message).to have_content('Finished!')
    expect(show_message[:class].include?('alert fade in alert-info')).to be_true
    # Check result scissor win over lizard, player 1 win
    game_summary = page.find_by_id('game_summary')
    expect(game_summary).to have_content('Summary: 1 - 0 You win!')
    expect(game_summary[:class].include?('success')).to be_true



  end






end



