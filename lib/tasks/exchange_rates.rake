namespace :exchange_rates do
  desc 'Populates the database with exchange rates'
  task load: :environment do
    feeder = ExchangeRatesFeeder.new(from_currency: 'USD', to_currency: 'EUR')

    feeder.feed!
  end
end
