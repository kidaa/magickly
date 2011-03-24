require 'rubygems'
require 'bundler'
Bundler.require

require 'sinatra/base'
require 'dragonfly'
require File.join(File.dirname(__FILE__), 'dragonfly', 'data_storage', 'remote_data_store')


class MagicklyApp < Sinatra::Base
  # use Dragonfly::Middleware, :images
  
  app = Dragonfly[:images].configure_with(:imagemagick)
  app.datastore = Dragonfly::DataStorage::RemoteDataStore.new
  
  before do
    app.datastore.configure do |d|
      d.cookie_str = request.env["rack.request.cookie_string"]
    end
  end
  
  get '/' do
    src = params.delete('src')
    image = app.fetch(src)
    
    # TODO handle non-ordered hash
    params.each do |method, val|
      image = image.process method, val
    end
    
    image.to_response(env)
  end
  
  # start the server if ruby file executed directly
  run! if app_file == $0
end
