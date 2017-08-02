module Test
  module Update
    extend self
    extend NewShare

    def hitter_box_scores(game)
      home_team = game.home_team
      url = "https://www.baseball-reference.com/boxes/#{home_team.game_abbr}/#{game.url}.shtml"
      puts url
      team_name = home_team.name.tr(" ", "")
      city = home_team.city.tr(" ", "")
      css = "##{city}#{team_name}batting tbody .left , ##{city}#{team_name}batting tbody .right"
      css = "td"
      puts css
      doc = download_document(url)
      elements = doc.css(css)
      puts elements.size
      elements.each_slice(22) do |slice|
        puts slice[0].text
      end

    end

  end
end
