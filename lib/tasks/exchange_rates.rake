namespace :exchange_rates do
  desc 'Populates the database with exchange rates'
  task :load, [:arg1, :arg2] => :environment do |t, args|
    puts 'Feeding database with exchange rates...'

    from_currency = args[:arg1] || 'USD'
    to_currency = args[:arg2] || 'EUR'

    feeder = ExchangeRatesFeeder.new(from_currency: from_currency, to_currency: to_currency)

    feeder.feed!

    puts '... End of feeding database'
  end
end
