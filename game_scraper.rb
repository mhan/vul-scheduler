require 'rubygems'
require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'sqlite3'

class GameScraper
  def collect_games
    url = URI.parse('http://vul.bc.ca/v3/team/schedule/')
    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    
    doc = Nokogiri::HTML(res.body)
    games = doc.xpath('//div[@id="content"]/table/tr/td[@class="tabledata"]/..')
    db = SQLite3::Database.new('games.db')
    db.execute('DELETE FROM GAMES WHERE id > 0')
    query = ''
    games.each do |game|
      game_data = game.xpath('td')
      gametime = game_data[0].content
      gametime = "2009-" + gametime
      gametime = Time.parse(gametime).strftime("%Y-%m-%d %H:%M:%S")
      field = game_data[1].content
      field_url = 'http://vul.bc.ca' + game_data[1].child.attribute('href')
      team1 = game_data[2].content
      team2 = game_data[3].content
      query += 'INSERT INTO games (gametime, field, field_url, team1, team2) VALUES ("' + gametime + '", "' + field + '", "' + field_url + '", "' + team1 + '", "' + team2 + '");'
    end
    db.execute_batch(query)
  end
  
  def collect_teams
    doc = Nokogiri::HTML(open('http://vul.bc.ca/v3/team/'))
    teams = doc.xpath('//td[@class="tabledata"]/a')
    query = ''
    teams.each do |team|
      url = 'http://www.vul.bc.ca' + team.attribute('href')
      query += 'INSERT INTO teams (name, url) VALUES ("' + team.content + '", "' + url + '");'
    end
    db = SQLite3::Database.new('games.db')
    db.execute("DELETE FROM TEAMS WHERE id > 0")
    db.execute_batch(query)
    #puts query
  end
end

gs = GameScraper.new
gs.collect_games
gs.collect_teams