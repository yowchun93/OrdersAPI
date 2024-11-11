class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.string :product_name, null: false
      t.integer :quantity, null: false
      t.decimal :price, null: false
      t.string :status, null: false

      t.timestamps
    end
  end
end
