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
  @user.update_attributes(payload)

  content_type :json
  @user.to_json
end

post '/users/check' do
  payload = JSON.parse(request.body.read).symbolize_keys
  @user = User.find_by(email: payload[:email])
  Digest::MD5.hexdigest(payload[:password])
end
