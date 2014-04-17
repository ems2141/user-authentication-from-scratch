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
    new_id = @user_table.insert(email: params[:user_email], password: hashed_password)
    session[:user_id] = new_id
    redirect '/'
  end

  get '/login' do
    erb :login, locals: {error: nil}
  end

  post '/login' do
    user = @user_table[email: params[:login_email]]
    if user.nil? || !passwords_match?(user, params[:login_password])
      error = "Email / Password is invalid"
      erb :login, locals: {error: error}
    else
      session[:user_id] = user[:id]
      redirect '/'
    end
  end

  get '/logout' do
    session.clear
    redirect '/'
  end

  get '/users' do
    user = @user_table[id: session[:user_id]]
    if user && user[:administrator]
      users = @user_table.to_a
      erb :users, locals: {user: user, users: users}
    else
      erb :error
    end
  end

  private

  def passwords_match?(user, entered_password)
    BCrypt::Password.new(user[:password]) == entered_password
  end

end
