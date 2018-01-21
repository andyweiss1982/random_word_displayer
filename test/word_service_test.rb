require "typhoeus"
require "test/unit"
require "./services/word_service"

class TestWordService < Test::Unit::TestCase

  def test_fifty_fifty_working
    word_service  = WordService.new(authenticated: true)
    response      = Typhoeus::Response.new(code: 200, body: "stubbed_word")
    Typhoeus.stub(word_service.send(:url)).and_return(response)

    assert(word_service.get_word == "stubbed_word")
  end

  def test_fifty_fifty_not_working
    word_service  = WordService.new(authenticated: true)
    response      = Typhoeus::Response.new(code: 500, body: nil)
    Typhoeus.stub(word_service.send(:url)).and_return(response)

    assert_raise(WordService::ServiceUnavailableError) do
      word_service.get_word
    end
  end

  def test_unauthenticated
    word_service  = WordService.new(authenticated: false)
    response      = Typhoeus::Response.new(code: 401, body: nil)
    Typhoeus.stub(word_service.send(:url)).and_return(response)

    assert_raise(WordService::NotAuthorizedError) do
      word_service.get_word
    end
  end

end
