json.array!(@games) do |game|
  json.extract! game, :id, :uid, :moves
  json.url game_url(game, format: :json)
end
