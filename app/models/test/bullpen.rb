module Test
  class Bullpen

    def whoo
      Game.all.each do |game|
        fetch_weather_data(game)
      end
    end

    def headers
      %w(
      id
      url
      date\ -\ month
      date\ -\ day
      date\ -\ year
      time\ of\ game\ -\ with\ AM/PM
      away\ team
      home\ team
      temperature1
      temperature2
      temperature3
      conditions
      wind\ speed1
      wind\ speed2
      wind\ speed3
      wind\ direction1
      wind\ direction2
      wind\ direction3
      DP1
      DP2
      DP3
      humid1
      humid2
      humid3
      air\ density1
      air\ density2
      air\ density3
      barometric\ pressure1
      barometric\ pressure2
      barometric\ pressure3
      away\ score
      home\ score
      total\ score
      total\ hits\ combined
      total\ walks\ combined
      walks\ +\ hits\ combined
      totals\ bases\ combined
      1st\ inning\ away\ score
      2nd\ inning\ away\ score
      3rd\ inning\ away\ score
      4th\ inning\ away\ score
      5th\ inning\ away\ score
      6th\ inning\ away\ score
      7th\ inning\ away\ score
      8th\ inning\ away\ score
      9th\ inning\ away\ score
      10th\ inning\ away\ score
      -blank-
      1st\ inning\ home\ score
      2nd\ inning\ home\ score
      3rd\ inning\ home\ score
      4th\ inning\ home\ score
      5th\ inning\ home\ score
      6th\ inning\ home\ score
      7th\ inning\ home\ score
      8th\ inning\ home\ score
      9th\ inning\ home\ score
      10th\ inning\ home\ score
      -blank-
      HR’s\ combined
      SB’s\ combined
      away\ starter\ 1st\ name
      away\ starter\ last\ name
      away\ starter\ R/L
      home\ starter\ 1st\ name
      home\ starter\ last\ name
      home\ starter\ R/L
      )
    end

    def fetch_weather_data(game)
      return game.weathers.where(station: "Actual").map do |weather|
        wind_speed = weather.wind.scan(/\d*\.?\d*/)[0]
        wind_dir = weather.wind.scan(/\w+$/)[0]
        temp = weather.temp.scan(/\d*/)[0]
        pressure = weather.pressure.scan(/\d*\.\d*/)[0]
        dew = weather.dew.scan(/\d*/)[0]
        {
          wind_speed: wind_speed,
          wind_dir: wind_dir,
          humidity: weather.humidity,
          temp: temp,
          rain: weather.rain,
          pressure: pressure,
          dew: dew,
          feel: weather.feel,
          speed: weather.speed,
          dir: weather.dir,
          air_density: weather.air_density
        }
      end
    end

    def test
      CSV.open("weather-data.csv", "wb") do |csv|
        csv << headers
        GameDay.all.order("date").each do |game_day|
          date = game_day.date
          puts date
          game_day.games.each do |game|
            if game.home_team && game.away_team
              url = game.url

              walks = 0
              hits = 0
              home_runs = 0

              away_score = 0
              game.hitter_box_scores.where(home: false).each do |hitter|
                hits += hitter.H
                walks += hitter.BB
                home_runs += hitter.HR
                away_score += hitter.R
              end

              home_score = 0
              game.hitter_box_scores.where(home: true).each do |hitter|
                hits += hitter.H
                walks += hitter.BB
                home_runs += hitter.HR
                home_score += hitter.R
              end

              away_innings = Array.new(10)
              home_innings = Array.new(10)
              game.innings.each_with_index do |inning, index|
                if index < 10
                  away_innings[index] = inning.away
                  home_innings[index] = inning.home
                end
              end

              if game.weathers.where(station: "Actual").size != 0
                weather_data = fetch_weather_data(game)

                weather_hash = {}
                weather_data.each_with_index do |weather, index|
                  weather.each do |key, data|
                    weather_hash[key] ||= []
                    weather_hash[key][index] = data
                  end
                end
              else
                keys = [:wind_speed, :wind_dir, :humidity, :temp, :rain, :pressure, :dew, :feel, :speed, :dir, :air_density]
                weather_hash = {}
                keys.each do |key|
                  weather_hash[key] = Array.new(3)
                end
              end

              starters = game.lancers.where(starter: true)
              away_starter = nil
              home_starter = nil
              starters.each do |starter|
                away_starter = starter if starter.team == game.away_team
                home_starter = starter if starter.team == game.home_team
              end

              if away_starter && home_starter
                away_starter_name = away_starter.player.name.split(" ")
                home_starter_name = home_starter.player.name.split(" ")
                away_starter_first_name = away_starter_name[0]
                away_starter_last_name = away_starter_name[1..-1].join(" ")
                away_starter_handedness = away_starter.player.throwhand
                home_starter_first_name = home_starter_name[0]
                home_starter_last_name = home_starter_name[1..-1].join(" ")
                home_starter_handedness = home_starter.player.throwhand
              end

              data = [game.id, game.url, date.month, date.day, date.year, game.time, game.away_team.name, game.home_team.name]
              data += weather_hash[:temp]
              # conditions
              data += [nil]
              data += weather_hash[:wind_speed]
              data += weather_hash[:wind_dir]
              data += weather_hash[:dew]
              data += weather_hash[:humidity]
              data += weather_hash[:air_density]
              data += weather_hash[:pressure]
              data += [away_score, home_score, away_score + home_score]
              # bases combined
              data += [hits, walks, walks + hits, nil]
              data += [away_starter_first_name, away_starter_last_name, away_starter_handedness]
              data += [home_starter_first_name, home_starter_last_name, home_starter_handedness]
              data += away_innings
              data += [nil]
              data += home_innings
              data += [nil]
              # stolen bases
              data += [home_runs, nil]
              data += [away_starter_first_name, away_starter_last_name, away_starter_handedness]
              data += [home_starter_first_name, home_starter_last_name, home_starter_handedness]
              csv << data
            end
          end
        end
      end
    end

    def text_file
      CSV.open("weather-data.txt", "wb") do |csv|
        GameDay.order("date DESC") do |game_day|
          puts game_day.date
          game_day.games.each do |game|
            puts game.id
            puts game.away_team.name
            csv << [game.id, game.away_team.name, game.home_team.name]
          end
        end
      end
    end


    def run
      [GameDay.yesterday, GameDay.today, GameDay.tomorrow].each do |game_day|
        bullpen_hash = get_bullpen_hash(game_day)
        bullpens_valid = true
        game_day.games.each do |game|
          unless bullpen_valid?(game, bullpen_hash)
            puts game.id
            bullpens_valid = false
            game.lancers.where(bullpen: true).destroy_all
          end
        end
        game_day.create_bullpen unless bullpens_valid
      end
    end

    private

      def get_bullpen_hash(game_day)
        bullpen_teams = [1, 2, 3, 4, 12, 13, 17, 21, 22, 23, 26, 27, 28, 29, 30, 5, 6, 7, 8, 9, 10, 11, 14, 15, 16, 18, 19, 20, 24, 25]
        date = game_day.date
        url = "http://www.baseballpress.com/bullpenusage/#{date.strftime("%Y-%m-%d")}"
        doc = Nokogiri::HTML(open(url))
        element_array = doc.css(".league td")
        players = element_array.select { |element| element.children.size == 2 || element.text == "Pitcher" }

        team_index = -1
        players = players.map do |player|
          if player.text == "Pitcher"
            team_index += 1
            Team.find(bullpen_teams[team_index]).name
          else
            name = player.child.text
            identity = player.child['data-bref']
            [name, identity]
          end
        end
        players = players.chunk { |player|
          player.class == String
        }
        bullpen_hash = Hash.new
        players = players.to_a.each_slice(2) do |slice|
          team = slice[0][1][0]
          players = slice[1][1]
          bullpen_hash[team] = players
        end
        return bullpen_hash
      end

      def bullpen_valid?(game, bullpen_hash)

        away_team = game.away_team
        home_team = game.home_team
        away_bullpen = bullpen_hash[away_team.name]
        home_bullpen = bullpen_hash[home_team.name]
        game_away_bullpen = game.lancers.where(bullpen: true, team: away_team)
        game_home_bullpen = game.lancers.where(bullpen: true, team: home_team)

        if game_away_bullpen.size != away_bullpen.size || game_home_bullpen.size != home_bullpen.size
          return false
        end

        away_bullpen_names = away_bullpen.map { |bullpen| bullpen[0] }
        away_bullpen_identities = away_bullpen.map { |bullpen| bullpen[1] }

        game_away_bullpen.each do |bullpen|
          unless away_bullpen_names.include?(bullpen.name)
            puts bullpen.name
            return false
          end
          unless away_bullpen_identities.include?(bullpen.identity)
            puts bullpen.identity
            return false
          end
        end

        home_bullpen_names = home_bullpen.map { |bullpen| bullpen[0] }
        home_bullpen_identities = home_bullpen.map { |bullpen| bullpen[1] }

        game_home_bullpen.each do |bullpen|
          unless home_bullpen_names.include?(bullpen.name)
            puts bullpen.name
            return false
          end
          unless home_bullpen_identities.include?(bullpen.identity)
            puts bullpen.identity
            return false
          end
        end

        return true
      end

  end
end
