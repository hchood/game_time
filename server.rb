require 'sinatra'
require 'csv'
require 'pry'

def read_data_from(csv)
  results = []

  CSV.foreach(csv, headers: true) do |row|
    # results << row.to_hash
    result = { home_team: row['home_team'],
               away_team: row['away_team'],
               home_score: row['home_score'].to_i,
               away_score: row['away_score'].to_i
              }
    results << result
  end

  results
end

def create_team_records(results)
  # scoreboard_template = [{ name: "Patriots", wins: 0, losses: 0}, {}]
  leaderboard = create_team_scoreboard(results)

  results.each do |game|
    home_team_hash = find_team_hash(leaderboard, game[:home_team])
    away_team_hash = find_team_hash(leaderboard, game[:away_team])

    # if home team wins, increment home team's wins & away team's losses
    if game[:home_score] > game[:away_score]
      home_team_hash[:wins] += 1
      away_team_hash[:losses] += 1
    # if home team loses, increment away team's wins & home team's losses
    elsif game[:home_score] < game[:away_score]
      home_team_hash[:losses] += 1
      away_team_hash[:wins] += 1
    end
    # otherwise the teams tied - do nothing
  end

  leaderboard
end

def find_team_hash(leaderboard, team_name)
  team_hash = nil

  leaderboard.each do |team_record|
    if team_record[:name] == team_name
      team_hash = team_record
    end
  end

  team_hash
end

def create_team_scoreboard(results)
  scoreboard_template = []

  # create a list of team names
  team_names = []
  results.each do |game|
    team_names << game[:home_team]
    team_names << game[:away_team]
  end

  team_names.uniq!

  # create a hash for each team name inside team_records

  team_names.each do |team|
    scoreboard_template << { name: team, wins: 0, losses: 0 }
  end

  scoreboard_template
end

def sort_results(results)
  results.sort_by! do |result|
    -result[:wins]
  end
end

get '/leaderboard' do
  # read in game data from csv
  game_results = read_data_from('nfl_results.csv')

  # create our data structure
  team_records = create_team_records(game_results)

  # sort results from csv
  @team_records = sort_results(team_records)

  erb :index
end
