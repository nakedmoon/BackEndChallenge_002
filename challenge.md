== README

* Ruby/Rails version
  Ruby 2.1 - Rails 4.1

* Databases: SQLite, Redis Server (default network configuration)

* Database creation: rake db:create

* Database initialization: rake db:migrate

* Test suite: Rspec, DatabaseCleaner, Capybara

* Web Server: Puma Web Server (concurrent web server for use with ActionController::Live)

* Frontend: Twitterbootstrap, Haml, Coffescript

* How to run the test suite: bundle exec rspec

* Additional notes
 Test suites cover the model (rspec/models) and a full match using Capybara (rspec/views)
The game players must have different sessions, so both players must be play it with different browsers.

* Architecture description
  First player generate new game and the system create a new empty game with a uuid.
  The user can play a game accessing the game index or waiting a redirect after new game generation.
  First player play the this new game and system initialize the first player based on his "session id".
  Now the game is "waiting for an adversary", and the user is unable to submit and select weapons.
  Second player join the same game and now the game is "ready to fight".
  When second user join the game first user fight form will become enabled and both players can submit our moves
  When a player submit his moves he will be redirected to result page, but the game is "waiting for finish"
  When the other player submit his moves, finally first and second player can view result based on their sessions (the system write customized message to different players)
  First and second player communicate by a websocket; this "websocket" is provided using Redis Server "subscribe/publish" feature with the new Rails 4 feature "ActionController::Live".

