

require 'rack'
require 'pp'
require 'warden'


class Application

  def call(env)
    request = Rack::Request.new(env)
    response = if request.path_info = '/'
                 body = "#{request.request_method}: Hello! #{request.params['name']}!"
                 Rack::Response.new(body, "200", {'Content-Type' => 'text/plain'})
               else
                 Rack::Response.new('Not Found', "404", {'Content-Type' => 'text/plain'})
                 n
               end
    response.finish
  end

end


app = Rack::Builder.new do
  use Rack::Session::Cookie, :secret => "replace this with some secret key"

  use Warden::Manager do |manager|
    manager.default_strategies :password, :basic
    #manager.failure_app = BadAuthenticationEndsUpHere
  end

  run lambda { |env| Application.new().call(env) }
end

run app
