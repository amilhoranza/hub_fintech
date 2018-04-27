class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions, id: false do |t|
      t.string :uuid, limit: 36, primary: true, null: false
      t.integer :from, default: 0
      t.integer :to, default: 0
      t.integer :kind, default: 0
      t.string :description
      t.decimal :amount, :precision => 11, :scale => 2, default: 0
      t.integer :reversed, default: 0
      t.timestamps
    end
    add_index(:transactions, :uuid, unique: true)
  end
end
