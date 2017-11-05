require 'csv'

class CsvParser
  attr_reader :path_to_file, :from_currency, :to_currency
  attr_accessor :csv

  def initialize(path_to_file: "exchange_rates/#{Rails.env}/exchange_rates.csv", from_currency: 'USD', to_currency: 'EUR')
    @path_to_file = path_to_file
    @from_currency = from_currency
    @to_currency = to_currency
  end

  def parse
    csv_text = File.read(path_to_file)
    @csv = CSV.parse(csv_text)

    remove_headers
    reverse_csv
    remove_entries_before!(Date.parse('1999-12-30'))
    store_exchange_rates
  end

  #######
  private
  #######

  def store_exchange_rates
    previous_date = Date.parse(csv.first.first)
    previous_rate = csv.first.second

    csv.each do |row|
      begin
        current_date = Date.parse(row.first)

        if current_date.year < 2000
          previous_date = Date.parse(row.first)
          previous_rate = row.second if row.second != '-'

          next
        end

        unless current_date - previous_date == 1
          ((previous_date + 1.day)..(current_date - 1.day)).each do |date|
            store_exchange_rate(date: date, rate: previous_rate) unless date.year < 2000
          end
        end

        unless row.second == '-'
          previous_rate = row.second
        end
        previous_date = Date.parse(row.first)

        store_exchange_rate(date: previous_date, rate: previous_rate)

      rescue => ex
        Rails.logger.error "Failed to store exchange rate for date: #{row.first}. Exception: #{ex.message}"
        raise ex
      end
    end
  end

  def store_exchange_rate(date:, rate:)
    exchange_rate = ExchangeRate.where(date: date, from_currency: from_currency, to_currency: to_currency).first

    if exchange_rate.present?
      exchange_rate.rate = rate
    else
      exchange_rate = ExchangeRate.new(from_currency: from_currency,
                                       to_currency: to_currency,
                                       date: date,
                                       rate: rate)
    end

    exchange_rate.save!
  end

  def reverse_csv
    csv.reverse!
  end

  def remove_headers
    5.times { csv.shift }
  end

  def remove_entries_before!(starting_date)
    while starting_date > Date.parse(csv.first.first)
      csv.shift
    end
  end
end