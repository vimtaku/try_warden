

require 'rack'
require 'pp'
require 'warden'


class Application

  def call(env)
    request = Rack::Request.new(env)
    p "Authenticate!!!!!!!!!!!!"
    env['warden'].authenticate!

    p "warden user is "
    p env['warden'].user

    response = if request.path_info = '/'
                 body = "#{request.request_method}: Hello! #{request.params['name']}!"
                 Rack::Response.new(body, "200", {'Content-Type' => 'text/plain'})
               else
                 Rack::Response.new('Not Found', "404", {'Content-Type' => 'text/plain'})
               end
    response.finish
  end

end


class User
  attr_reader :id

  def initialize(id)
    @id = id
  end
  def self.get(id)
    ## 永続化されたものから引いてうまく引けたと過程して返す
    return User.new(id)
  end

  def self.authenticate(username, password)
    ## 永続化されているものから引っ張ってdigest でゴニョゴニョしたと
    ## 仮定してうまく行った結果を返す
    ## おそらくここではユーザインスタンスを返すのが正解
    return User.new(1)
  end
end

class BadAuthenticationEndsUpHere
  def self.call(env)
    p "in BadAuthenticationEndsUpHere!!!!!!!!!!!!"
    request = Rack::Request.new(env)

    p "request.path_info is "
    p request.path_info

    Rack::Response.new('Not Found', "404", {'Content-Type' => 'text/plain'})
  end
end



Warden::Strategies.add(:password) do

  def valid?
    p "valid? called"
    params['username'] || params['password']
  end


  def authenticate!
    p "halt!!!!!!!!!"
    halt!
    return nil
    p "in authenticate! session is "
    p session
    u = User.authenticate(params['username'], params['password'])
    u.nil? ? fail!("Could not log in") : success!(u)
  end
end



app = Rack::Builder.new do
  use Rack::Session::Cookie, :secret => "replace this with some secret key"

  use Warden::Manager do |manager|
    manager.default_strategies :password,:basic
    manager.failure_app = BadAuthenticationEndsUpHere

    manager.serialize_into_session do |user|
    p "serialize into session!!!!!!!!!!!!"
      user.id
    end

    manager.serialize_from_session do |id|
    p "serialize from session!!!!!!!!!!!!"
      User.get(id)
    end

  end

  run lambda { |env| Application.new().call(env) }
end

run app
