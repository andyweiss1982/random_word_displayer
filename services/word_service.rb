require "typhoeus"

class WordService
  TIMEOUT       = 3
  MAX_ATTEMPTS  = 15

  class NotAuthorizedError < StandardError
    attr_reader :code

    def initialize(message="You are not authorized to get words. Try making an authenticated request.", code=401)
      @code = code
      super(message)
    end
  end

  class ServiceUnavailableError < StandardError
    attr_reader :code

    def initialize(message="Could not get a word in #{TIMEOUT} seconds or less. Please try again.", code=503)
      @code = code
      super(message)
    end
  end

  def initialize(authenticated: true)
    @authenticated = authenticated
  end

  def get_word
    hydra = Typhoeus::Hydra.new
    MAX_ATTEMPTS.times do |attempt|
      request = Typhoeus::Request.new(url, headers: headers, timeout: TIMEOUT)
      request.on_complete do |response|
        return response.body if response.code == 200
        raise NotAuthorizedError.new if response.code == 401
        raise ServiceUnavailableError.new if response.timed_out?
      end
      hydra.queue(request)
    end
    hydra.run
    raise ServiceUnavailableError.new
  end

  private

  def url
    host      = ENV.fetch('FIFTY_FIFTY_HOST')
    protocol  = host.include?('localhost') ? 'http' : 'https'
    path      = "/fifty_fifty"
    @url      ||= "#{protocol}://#{host}#{path}"
  end

  def headers
    if @authenticated
      @headers ||= {Authorization: "Bearer #{ENV.fetch('FIFTY_FIFTY_AUTH_TOKEN')}"}
    else
      {}
    end
  end
end
