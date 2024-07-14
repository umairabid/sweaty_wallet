# MainApp

App is developed on Ruby and Rails in its full stack form. The stack includes

- `postgres` for database
- `devise` for user management and authentication
- `ferrum` for running a headless browser
- `mailcatcher` for catching emails locally
- `good_job` for ActiveJob adapter
- `hotwire` for frontend
- `tailwind` for css

## Development

- Install `ruby '3.3.1'`
- Install `rails '7.1.3'`
- Install `postgres@16`
- Clone repo
- Run `db:setup`, to setup the database and create user `user@example.com/123456`
- Setup extension
- If you are using ubuntu and want to setup browser for headless scraping run `./bin/install-chromium-ubuntu`
- Run the server with `./bin/dev`