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

get '/leaderboard' do
  # read in game data from csv
  game_results = read_data_from('nfl_results.csv')

  # sort results from csv
  @team_records = sort_results(game_results)

  erb :index
end
