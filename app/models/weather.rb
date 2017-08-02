class Weather < ActiveRecord::Base
  belongs_to :game

  def temp_num
    return 0.0 if temp.size == 0
    index = temp.index(".")
    index ? temp[0..index+1].to_f : temp[0..1].to_f
  end

  def dew_num
    return 0.0 if temp.size == 0
    index = dew.index(".")
    index ? dew[0..index+1].to_f : dew[0..1].to_f
  end

  def humid_num
    return 0.0 if humidity.size == 0
    humidity[0..1].to_f
  end

  def baro_num
    pressure.include?(".") ? (pressure[0...-3].to_i * 33.86375257787817).round(2) : 0.0
  end

  def air_density
    unless baro_num == 0.0 || dew_num == 0.0 || temp_num == 0.0
      Create::AirDensity.new.run(baro_num, temp_num, dew_num)
    else
      0.0
    end
  end

  def total_runs1_count
    Workbook.where("TEMP <= ? AND TEMP >= ?", temp+5, temp-5)
    .where("DP <= ? AND DP >= ?", dew+2, dew-2)
    .where("HUMID <= ? AND HUMID >= ?", humidity+3, humidity-3)
    .where("BARo <= ? AND BARo >= ?", pressure+5, pressure-5)
    .count(:f18)
  end

  def total_runs1_avg
    Workbook.where("TEMP <= ? AND TEMP >= ?", temp+5, temp-5)
    .where("DP <= ? AND DP >= ?", dew+2, dew-2)
    .where("HUMID <= ? AND HUMID >= ?", humidity+3, humidity-3)
    .where("BARo <= ? AND BARo >= ?", pressure+5, pressure-5)
    .average(:f18)
  end

  def total_runs2_count
    Workbook.where("TEMP <= ? AND TEMP >= ?", temp+5, temp-5)
    .where("DP <= ? AND DP >= ?", dew+2, dew-2)
    .where("HUMID <= ? AND HUMID >= ?", humidity+3, humidity-3)
    .where("BARo <= ? AND BARo >= ?", pressure+5, pressure-5)
    .count(:Total_Hits)
  end

  def total_runs2_avg
    Workbook.where("TEMP <= ? AND TEMP >= ?", temp+5, temp-5)
    .where("DP <= ? AND DP >= ?", dew+2, dew-2)
    .where("HUMID <= ? AND HUMID >= ?", humidity+3, humidity-3)
    .where("BARo <= ? AND BARo >= ?", pressure+5, pressure-5)
    .average(:Total_Hits)
  end

  def total_hits_count
    Workbook.where("TEMP <= ? AND TEMP >= ?", temp+5, temp-5)
    .where("DP <= ? AND DP >= ?", dew+2, dew-2)
    .where("HUMID <= ? AND HUMID >= ?", humidity+3, humidity-3)
    .where("BARo <= ? AND BARo >= ?", pressure+5, pressure-5)
    .count(:Total_Walks)
  end

  def total_hits_avg
    Workbook.where("TEMP <= ? AND TEMP >= ?", temp+5, temp-5)
    .where("DP <= ? AND DP >= ?", dew+2, dew-2)
    .where("HUMID <= ? AND HUMID >= ?", humidity+3, humidity-3)
    .where("BARo <= ? AND BARo >= ?", pressure+5, pressure-5)
    .average(:Total_Walks)
  end

  def home_runs_count
    Workbook.where("TEMP <= ? AND TEMP >= ?", temp+5, temp-5)
    .where("DP <= ? AND DP >= ?", dew+2, dew-2)
    .where("HUMID <= ? AND HUMID >= ?", humidity+3, humidity-3)
    .where("BARo <= ? AND BARo >= ?", pressure+5, pressure-5)
    .count(:home_runs)
  end

  def home_runs_avg
    Workbook.where("TEMP <= ? AND TEMP >= ?", temp+5, temp-5)
    .where("DP <= ? AND DP >= ?", dew+2, dew-2)
    .where("HUMID <= ? AND HUMID >= ?", humidity+3, humidity-3)
    .where("BARo <= ? AND BARo >= ?", pressure+5, pressure-5)
    .average(:home_runs)
  end
end
