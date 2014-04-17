require 'sinatra/base'
require 'bcrypt'

class Application < Sinatra::Application

  enable :sessions

  def initialize(app=nil)
    super(app)
    @user_table = DB[:users]
  end

  get '/' do
    user = @user_table[id: session[:user_id]]
    erb :index, locals: {user: user}
  end

  get '/register' do
    erb :registration
  end

  post '/register' do
    hashed_password = BCrypt::Password.create(params[:user_password])
    new_id = DB[:users].insert(email: params[:user_email], password: hashed_password)
    session[:user_id] = new_id
    redirect '/'
  end

  get '/login' do
    erb :login, locals: {error: nil}
  end

  post '/login' do
    user = @user_table[email: params[:login_email]]
    if user
      orig_password = BCrypt::Password.new(user[:password])
      if orig_password == params[:login_password]
        session[:user_id] = user[:id]
        redirect '/'
      else
        error = "Email / Password is invalid"
        erb :login, locals: {error: error}
      end
    else
      error = "Email / Password is invalid"
      erb :login, locals: {error: error}
    end
  end

  get '/logout' do
    session.clear
    redirect '/'
  end

  get '/users' do
    users = @user_table.to_a
    user = @user_table[id: session[:user_id]]
    if user[:administrator]
      erb :users, locals: {user: user, users: users}
    else
      "You do not have rights to visit this page."
    end
  end
end
