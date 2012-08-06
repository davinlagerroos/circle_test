class CreateForecastTypes < ActiveRecord::Migration
  def change
    create_table :forecast_types do |t|
      t.string :name

      t.timestamps

      t.boolean :active, :default => true
      t.boolean :internal, :default => false
      t.boolean :copyable, :default => false
    end
  end
end
