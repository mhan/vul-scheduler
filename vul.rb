require 'sqlite3'
require 'dm-core'
require 'dm-serializer'
require 'json'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/games.db")

class Game
  include DataMapper::Resource
  property :id, Serial
  property :gametime, DateTime
  property :field, Text
  property :field_url, Text
  property :team1, Text
  property :team2, Text

  def pretty_gameday
    self.gametime.strftime("%A %B %d")
  end

  def pretty_gametime
    self.gametime.strftime("%I:%M %p")
  end
end

class Team
  include DataMapper::Resource

  property :id, Serial
  property :name, Text
  property :url, Text
end

get '/' do
  @today_games = Game.all(:gametime.gt => DateTime.now - 1, :gametime.lt => DateTime.now)
  erb :vul
end

get '/team_search' do
  query = params[:value]
  teams = Team.all(:conditions => ['name LIKE ?', query + '%'])
  res = []
  teams.each do |team|
    res.push team.name
  end
  res.to_json
end

get '/games' do
  name = params[:name]
  # Always do time comparisons in PST
  pst = DateTime.now.new_offset(Rational(-7,24))
  games = Game.all(:conditions => ["(team1 = ? OR team2 = ?) AND gametime > ?", name, name, pst - 1], :order => [:gametime.asc])
  @later_games = []
  @today_games = []
  if (!games.empty?)
    first_date = games.first.gametime
    games.each do |game|
      if (game.gametime >= first_date && game.gametime < first_date + 1)
        @today_games.push(game)
      else
        @later_games.push(game)
      end
    end
  end
  erb :games
end