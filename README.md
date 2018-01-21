# random_word_displayer

* Connects with `fifty_fifty` via token authentication
* Depends on `FIFTY_FIFTY_HOST` and `FIFTY_FIFTY_AUTH_TOKEN` environment variables being set
* Single `/home` endpoint
* WordService class wraps the connection with `fifty_fifty`
* WordService#get_word attempts to get a word
  - It will retry up to 15 times for up to 3 seconds
  - Fires parallel requests to increate likelihood of getting a successful response in less than 3 seconds
  - If `fifty_fifty` returns a 401, it will raise a NotAuthorizedError
  - If it only receives a series of 500's for three seconds, it will bail and raise a `ServiceUnavailableError` with a code of 503
* The user will reliably either see the word returned by the service, or an error and a code.
* Unit tests on WordService and Capybara Integration tests in the `/test` folder
