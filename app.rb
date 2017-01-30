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

post '/users/login' do
  payload = JSON.parse(request.body.read).symbolize_keys
  @user = User.find_by(email: payload[:email])

  if @user.present? && Digest::MD5.hexdigest(payload[:password]) == @user[:password_hash]
    status 200
    content_type :json
    @user.to_json
  else
    status 401
    content_type :json
    { success: false }.to_json
  end
end
