class Date
  # Returns datetime value for date previous week began. This is a DI method, so weeks begin on Saturday.
  def self.start_of_last_di_week
    today = Date.today
    start_of_week = Date.today
    until start_of_week.cwday == 6 && ((today - start_of_week) > 6)
      start_of_week = start_of_week - 1
    end
    start_of_week.beginning_of_day
  end

  # Returns datetime value for date previous week ended.  This is a DI method, so weeks end on Friday. 
  def self.end_of_last_di_week
    (Date.start_of_last_di_week.to_date + 6).end_of_day
  end

  # Returns datetime value for date current week began. This is a DI method, so weeks begin on Saturday.
  def self.start_of_this_di_week
    (Date.start_of_last_di_week.to_date + 7).beginning_of_day
  end

  # Returns datetime value for date current week ends.  This is a DI method, so weeks end on Friday.
  def self.end_of_this_di_week
    (Date.start_of_this_di_week.to_date + 6).end_of_day
  end  
  
  def to_milliseconds
    self.to_time.to_f
  end
end
