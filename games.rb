require 'rubygems'
require 'sqlite3'
require 'dm-core'
require 'dm-serializer'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/games.db")

class Game
  include DataMapper::Resource
  property :id, Serial
  property :gametime, DateTime
  property :field, Text
  property :field_url, Text
  property :team1, Text
  property :team2, Text
end

class Team
  include DataMapper::Resource
  
  property :id, Serial
  property :name, Text
  property :url, Text
end
