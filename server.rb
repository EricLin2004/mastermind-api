require 'sinatra'
require 'json'
require 'securerandom'
require 'mongo'

require './master.rb'

include Mongo

MONGO_LOCK = {};

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
    body "Please provide a user parameter in your post request"
    return
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
  game_key = params['game_key']

  if MONGO_LOCK[game_key]
    status 400
    body "Processing last guess, please wait a moment for it to complete."
    return
  end

  MONGO_LOCK[game_key] = true

  unless game_key
    status 400
    MONGO_LOCK[game_key] = false
    body "Could not find game key. Please post with proper key!"
    return
  end

  player_guess = Code.sanitize(params['code'])

  unless params['code'] && player_guess
    status 400
    MONGO_LOCK[game_key] = false
    body "Invalid code submission. Please post with code parameter consisting of 8 letters of RBGYOPCM"
    return
  end

  game = collection.find({ 'game_key' => game_key }).first()

  unless game
    status 400
    MONGO_LOCK[game_key] = false
    body "Could not find game corresponding to provided game_key!"
    return
  end

  if game['solved'] == 'true'
    MONGO_LOCK.delete(game_key)
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

  answer_code = game['answer_code']
  game_object = Game.new(answer_code)
  result = game_object.display_matches(player_guess)
  past_results = game['past_results'] << { :guess => player_guess, :exact => result[0], :near => result[1] }

  collection.find_and_modify({
    query: { 'game_key' => game_key },
    update: {
      :user => game['user'],
      :game_key => game_key,
      :answer_code => answer_code,
      :num_guesses => game['num_guesses'] + 1,
      :start_time => game['start_time'],
      :solved => 'false',
      :colors => Code.colors,
      :code_length => Code.num_pegs,
      :past_results => past_results
    }
  })

  if game_object.win?(player_guess)
    time_taken = Time.now - game['start_time']

    collection.update({ 'game_key' => game_key }, {
      :user => game['user'],
      :game_key => game_key,
      :answer_code => answer_code,
      :num_guesses => game['num_guesses'],
      :past_results => past_results,
      :start_time => game['start_time'],
      :end_time => Time.now,
      :time_taken => time_taken,
      :colors => Code.colors,
      :code_length => Code.num_pegs,
      :solved => 'true'
    })

    MONGO_LOCK.delete(game_key)
    return {
      :user => game['user'],
      :game_key => game_key,
      :num_guesses => game['num_guesses'],
      :past_results => past_results,
      :guess => player_guess,
      :time_taken => time_taken,
      :solved => 'true',
      :colors => Code.colors,
      :code_length => Code.num_pegs,
      :result => "You win!"
    }.to_json
  end

  MONGO_LOCK[game_key] = false
  return {
    :game_key => game_key,
    :num_guesses => game['num_guesses'],
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