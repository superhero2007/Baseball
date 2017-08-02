namespace :job do

  task test: :environment do
    include NewShare
    url = "https://www.baseball-reference.com/players/split.fcgi?id=achteaj01&year=Career&t=p"
    doc = download_document(url)
    doc.css("#plato tbody .left , #plato .right").each do |elem|
      puts elem.text
    end

  end

  task daily: [:create_players, :update_batters, :update_pitchers, :update_hour_stadium_runs]

  task hourly: [:update_weather, :update_forecast, :update_games, :pitcher_box_score, :test_bullpen]

  task ten: [:create_matchups]

  task create_season: :environment do
    Season.create_seasons
  end
  
  task create_teams: :environment do
    Team.create_teams
  end

  task create_games: :environment do
    Season.all.each { |season| season.create_games }
  end

  task create_players: :environment do
    Season.where("year = 2017").each { |season| season.create_players }
  end

  task update_batters: :environment do
    Season.where("year = 2017").order("year DESC").each { |season| season.update_batters }
  end

  task update_pitchers: :environment do
    Season.where("year = 2017").map { |season| season.update_pitchers }
    Cleanup.prev_pitchers(GameDay.today)
    Cleanup.prev_pitchers(GameDay.tomorrow)
  end

  task create_matchups: :environment do
    [GameDay.yesterday, GameDay.today, GameDay.tomorrow].each { |game_day| game_day.create_matchups }
  end

  task update_games: :environment do
    GameDay.today.update_games
  end

  task update_weather: :environment do
    GameDay.yesterday.update_weather
    GameDay.today.update_weather
  end

  task update_forecast: :environment do
    [GameDay.today, GameDay.tomorrow].each { |game_day| game_day.update_forecast }
  end

  task pitcher_box_score: :environment do
    GameDay.yesterday.pitcher_box_score
  end

  task delete_games: :environment do
    GameDay.today.delete_games
  end

  task update_local_hour: :environment do
    Season.all.each { |season| season.game_days.each{ |game_day| game_day.update_local_hour } }
  end

  task update_hour_stadium_runs: :environment do
    Game.where(stadium: "").each do |game|
      game.update_hour_stadium_runs
    end
  end

  task fix_weather: :environment do
    GameDay.all.each do |game_day|
      game_day.update_weather
    end
  end

  task test_bullpen: :environment do
    Test::Bullpen.new.run
  end

  task fix_game_lancers: :environment do
    Game.all.each do |game|
      away_id = game.away_team_id
      home_id = game.home_team_id
      game.lancers.where.not("team_id = ? OR team_id = ?", away_id, home_id).destroy_all
    end
  end

 
  task fix: :environment do
    GameDay.find_or_create_by(season: Season.find_by_year('2017'), date: '2017-06-21').pitcher_box_score
  end

  task check: :environment do
    result = Workbook.where("TEMP <= ? AND TEMP >= ?", temp+5, temp-5)
    .where("DP <= ? AND DP >= ?", dew+2, dew-2)
    .where("HUMID <= ? AND HUMID >= ?", humidity+3, humidity-3)
    .where("BARo <= ? AND BARo >= ?", pressure+5, pressure-5)
    .count(:f18)
    puts result
  end

end
