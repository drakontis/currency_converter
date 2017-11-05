class ExchangeRateConverter
  def self.convert(amount, date_string, from_currency = 'USD', to_currency = 'EUR')
    date = Date.parse date_string

    if date > Date.today
      raise 'Invalid Date. Cannot convert for a date in future.'
    end

    exchange_rate = ExchangeRate.where(date: date, from_currency: from_currency, to_currency: to_currency).first

    ##
    # If the date of the latest entry in the database is smaller than the target date, I will try to convert the amount
    # using this (latest entry's) exchange rate.
    #
    # This scenario is possible when the rake task, that populates the database,
    # has already been executed, but the last days are holidays and the csv file does not contain an exchange rate for them.
    # So, if the user asks a conversion for these days we use the latest entry's exchange rate.
    #
    # The asc(:date) in the next where clause is added due to the nondeterministic behaviour of the first and last commands in MongoDB.
    # https://stackoverflow.com/questions/35039847/the-bug-of-mongoid-returning-first-document-when-invoking-last
    # https://stackoverflow.com/questions/16037852/get-last-record-in-monodb-using-ruby
    #
    if exchange_rate.nil?
      exchange_rate = ExchangeRate.where(from_currency: from_currency, to_currency: to_currency).asc(:date).last

      unless exchange_rate.present? || exchange_rate.date
        raise 'Cannot find exchange rate, please run the rake task to feed the database.'
      end
    end

    amount / exchange_rate.rate
  end
end