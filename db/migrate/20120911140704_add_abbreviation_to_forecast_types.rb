class AddAbbreviationToForecastTypes < ActiveRecord::Migration
  def change
    add_column :forecast_types, :abbreviation, :string
  end
end
