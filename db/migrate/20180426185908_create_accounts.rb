class CreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts do |t|
      t.string :name
      t.decimal :balance, :precision => 11, :scale => 2, default: 0
      t.integer :kind, default: 0
      t.integer :status, default: 0
      t.references :accountable, polymorphic: true

      t.timestamps
    end
    add_index :accounts, :name
  end
end
