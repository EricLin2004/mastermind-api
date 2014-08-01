require 'sinatra'
require 'json'
require 'securerandom'
require 'mongo'

require './master.rb'

include Mongo

conn = MongoClient.new
db = conn['eric-mastermind']
collection = db['games']

# Format post params when content_type is application/json or text/plain.
before do
  if request.content_type == "application/json"
    request.body.rewind
    params.merge!(JSON.parse(request.body.read))
  end
end

post('/new_game') do
  content_type :json

  new_game_key = SecureRandom.urlsafe_base64(50)
  new_code = Game.new.answer.code

  unless params['user']
    status 400
    return { :error => "Please provide a user parameter in your post request" }.to_json
  end

  collection.insert({
    :user => params[:user],
    :game_key => new_game_key,
    :num_guesses => 0,
    :answer_code => new_code,
    :start_time => Time.now,
    :solved => 'false',
    :colors => Code.colors,
    :code_length => Code.num_pegs,
    :past_results => []
  })

  return {
    :game_key => new_game_key,
    :num_guesses => 0,
    :solved => 'false',
    :colors => Code.colors,
    :code_length => Code.num_pegs,
    :past_results => []
  }.to_json
end

post('/guess') do
  content_type :json

  unless params['game_key']
    status 400
    return { :error => "Could not find game key. Please post with proper key!" }.to_json
  end

  player_guess = Code.sanitize(params['code'])

  unless params['code'] && player_guess
    status 400
    return { :error => "Invalid code submission. Please post with code parameter consisting of 8 letters of RBGYOPCM" }.to_json
  end

  game_key = params['game_key']
  game = collection.find({ 'game_key' => game_key }).first()

  unless game
    status 400
    return { :error => "Could not find game corresponding to provided game_key!" }.to_json
  end

  if game['solved'] == 'true'
    return {
      :user => game['user'],
      :game_key => game_key,
      :num_guesses => game['num_guesses'],
      :past_results => game['past_results'],
      :start_time => game['start_time'],
      :end_time => game['end_time'],
      :time_taken => game['time_taken'],
      :solved => 'true',
      :colors => Code.colors,
      :code_length => Code.num_pegs,
      :result => "This game has already been solved."
    }.to_json
  end

  num_guesses = game['num_guesses'] + 1
  answer_code = game['answer_code']

  game_object = Game.new(answer_code)

  result = game_object.display_matches(player_guess)
  past_results = game['past_results'] << { :guess => player_guess, :exact => result[0], :near => result[1] }

  if game_object.win?(player_guess)
    time_taken = Time.now - game['start_time']

    collection.update({ 'game_key' => game_key }, {
      :user => game['user'],
      :game_key => game_key,
      :answer_code => answer_code,
      :num_guesses => num_guesses,
      :past_results => past_results,
      :start_time => game['start_time'],
      :end_time => Time.now,
      :time_taken => time_taken,
      :colors => Code.colors,
      :code_length => Code.num_pegs,
      :solved => 'true'
    })

    return {
      :user => game['user'],
      :game_key => game_key,
      :num_guesses => num_guesses,
      :past_results => past_results,
      :guess => player_guess,
      :time_taken => time_taken,
      :solved => 'true',
      :colors => Code.colors,
      :code_length => Code.num_pegs,
      :result => "You win!"
    }.to_json
  end

  collection.update({ 'game_key' => game_key }, {
    :user => game['user'],
    :game_key => game_key,
    :answer_code => answer_code,
    :num_guesses => num_guesses,
    :start_time => game['start_time'],
    :solved => 'false',
    :colors => Code.colors,
    :code_length => Code.num_pegs,
    :past_results => past_results
  })

  return {
    :game_key => game_key,
    :num_guesses => num_guesses,
    :past_results => past_results,
    :guess => player_guess,
    :solved => 'false',
    :colors => Code.colors,
    :code_length => Code.num_pegs,
    :result => {
      :exact => result[0],
      :near => result[1]
    }
  }.to_json
end