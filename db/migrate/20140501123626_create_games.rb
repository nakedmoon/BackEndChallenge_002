class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :uid
      t.text :moves
      t.timestamps
    end
  end
end
