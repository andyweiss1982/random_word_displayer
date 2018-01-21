ENV["RACK_ENV"] = "test"

require "./word_displayer"
require "capybara"
require "capybara/dsl"
require "test/unit"

class IntegrationTest < Test::Unit::TestCase
  include Capybara::DSL

  def setup
    Capybara.app = WordDisplayer.new
  end

  def test_authenticated_request
    visit "/home"
    click_link("Fire Authenticated Request")
    assert(
      page.has_content?("You got a new word!") ||
      page.has_content?("Please try again.")
    )
  end

  def test_unauthenticated_request
    visit "/home"
    click_link("Fire Unauthenticated Request")
    assert page.has_content?("You are not authorized to get words.")
  end

  def test_overall_availability
    successes = 0
    visit "/home"
    10.times do
      click_link("Fire Authenticated Request")
      successes += 1 if page.has_content?("You got a new word!")
    end
    assert successes >= 9
  end
end
