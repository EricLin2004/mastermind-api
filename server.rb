require 'sinatra'
require 'json'
require 'securerandom'
require 'mongo'

require './master.rb'

include Mongo

conn = MongoClient.new
db = conn['eric-mastermind']
coll = db['games']

post('/new_game') do
  content_type :json

  new_game_key = SecureRandom.urlsafe_base64(50)
  new_code = Game.new.answer.code

  unless params['user']
    return { :error => "Please provide a user parameter in your post request"}
  end

  coll.insert({ :user => params[:user], :game_key => new_game_key, :num_guesses => 0, :answer_code => new_code, :past_guesses => [], :past_results => [] })
  { :game_key => new_game_key, :num_guesses => 0, :past_guesses => [], :past_results => [] }.to_json
end

post('/guess') do
  content_type :json
  unless params['game_key']
    return { :error => "Could not find game key. Please post with proper key!" }.to_json
  end

  player_guess = Code.sanitize(params['code'])

  unless params['code'] && player_guess
    return { :error => "Invalid code submission. Please post with code consisting of 4 letters: RBGY" }.to_json
  end

  game_key = params['game_key']
  game = coll.find({ 'game_key' => game_key }).first()

  past_guesses = game['past_guesses'] << player_guess
  num_guesses = game['num_guesses'] + 1
  answer_code = game['answer_code']

  game_object = Game.new(answer_code)

  result = game_object.display_matches(player_guess)
  past_results = game['past_results'] << result

  if game_object.win?(player_guess)
    return { :user => game['user'], :game_key => game_key, :num_guesses => num_guesses, :past_guesses => past_guesses, :past_results => past_results, :guess => player_guess, :result => "You win!" }.to_json
  end

  coll.update({ 'game_key' => game_key }, {:user => game['user'], :game_key => game_key, :answer_code => answer_code, :num_guesses => num_guesses, :past_guesses => past_guesses, :past_results => past_results })
  { :game_key => game_key, :num_guesses => num_guesses, :past_guesses => past_guesses, :past_results => past_results, :guess => player_guess, :result => ["You got #{result[0]} exact!","You got #{result[1]} near!"] }.to_json
end