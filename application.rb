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
    erb :registration, locals: {error: nil}
  end

  post '/register' do
    user = @user_table[email: params[:user_email]]
    if user.nil?
      if password_validation(params[:user_password], params[:pw_confirmation])
        hashed_password = BCrypt::Password.create(params[:user_password])
        new_id = @user_table.insert(email: params[:user_email], password: hashed_password)
        session[:user_id] = new_id
        redirect '/'
      else
        erb :registration, locals: {error: @error}
      end
    else
      error = "This email address has already been registered"
      erb :registration, locals: {error: error}
    end
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

  def password_validation(userpw, pwconfirm)
    if userpw.strip.length >= 3 && userpw == pwconfirm
      true
    elsif userpw.strip.empty?
      @error = "Password field cannot be blank"
      false
    elsif userpw.length < 3
      @error ="Password must be at least 3 characters"
      false
    else
      @error = "Passwords must match"
      false
    end
  end

  def passwords_match?(user, entered_password)
    BCrypt::Password.new(user[:password]) == entered_password
  end
end
