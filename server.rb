require 'sinatra'

enable :sessions

#############
# FUNCTIONS #
#############

use Rack::Session::Cookie, {
  secret: "keep_it_secret_keep_it_safe"
}

def winner(params)
  message = ""
  case true
  when params.has_value?("rock") && params.has_value?("paper")
    message = "#{params.invert["rock"]} chose rock, #{params.invert["paper"]} chose paper. #{params.invert["paper"]} scores."
    session["#{params.invert["paper"]}"] += 1
  when params.has_value?("scissors") && params.has_value?("rock")
    message = "#{params.invert["scissors"]} chose scissors, #{params.invert["rock"]} chose rock. #{params.invert["rock"]} scores."
    session["#{params.invert["rock"]}"] += 1
  when params.has_value?("paper") && params.has_value?("scissors")
    message = "#{params.invert["paper"]} chose paper, #{params.invert["scissors"]} chose scissors. #{params.invert["scissors"]} scores."
    session["#{params.invert["scissors"]}"] += 1
  else message = "Human chose #{params["Human"]}, A.I. chose #{params["A.I."]}. Tie, no winner."
  end
  message
end

###############
# CONTROLLERS #
###############

get '/' do
  if session["user_id"]
    session["user_id"] += 1
  else
    session["user_id"] = 1
  end
  redirect '/home'
end

get '/home' do
  if params["message"]
    erb :home, locals: { message: params["message"], score: { "Human" => session["Human"] , "A.I." => session["A.I."] } }
  else
    session["Human"] = 0
    session["A.I."] = 0
    erb :home, locals: { message: "" , score: { "Human" => session["Human"] , "A.I." => session["A.I."] } }
  end
end

post '/home' do
  if params["restart"]
    redirect '/home'
  else
    params["A.I."] = ["rock", "paper", "scissors"].sample
    message = winner(params)
    query = "message=#{message.gsub(' ', '%20')}"
    redirect "/home?#{query}"
  end
end
