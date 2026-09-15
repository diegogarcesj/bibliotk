class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.datetime :banned_at

      t.timestamps
    end
  end
end
