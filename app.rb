require 'rubygems'
require 'sinatra'
require 'active_record'
require 'json'
require 'digest/md5'

require './models'

configure do
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database =>  'users'
  )
end

get '/users' do
  content_type :json
  User.all.to_json
end

patch '/users/:id' do
  payload = JSON.parse(request.body.read).symbolize_keys
  @user = User.find(params[:id])
  @user.update_attribute(:email, payload[:email]) if payload[:email]
  @user.update_attribute(:fname, payload[:fname]) if payload[:fname]
  @user.update_attribute(:lname, payload[:lname]) if payload[:lname]
  @user.update_attribute(:birthday, payload[:birthday]) if payload[:birthday]
  @user.update_attribute(:password_hash, Digest::MD5.hexdigest(payload[:password])) if payload[:password]

  content_type :json
  @user.to_json
end

post '/users/login' do
  payload = JSON.parse(request.body.read).symbolize_keys
  @user = User.find_by(email: payload[:email])

  if Digest::MD5.hexdigest(payload[:password]) == @user[:password_hash]
    status 200
    content_type :json
    @user.to_json
  else
    status 401
  end
end
