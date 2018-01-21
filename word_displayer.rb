require "sinatra"
require "rack-flash"
require "./services/word_service"

class WordDisplayer < Sinatra::Base
  set :server, :puma
  enable :sessions
  use Rack::Flash

  helpers do
    def flash_class
      flash[:alert] ? "alert-warning" : flash[:notice] ? "alert-info" : ""
    end
  end

  get "/home" do
    word, error   = nil, nil
    get_word      = params[:get_word] == "true"
    authenticated = params[:authenticated] == "true"
    if get_word
      begin
        flash.now[:notice]  = "You got a new word!"
        word = WordService.new(authenticated: authenticated).get_word
      rescue StandardError => e
        flash.now[:alert]   = e.message
        error               = e.respond_to?(:code) ? e.code : 500
      end
    end
    erb :home, locals: {word: word, error: error}
  end

  get '/*' do
    redirect "/home"
  end

end
