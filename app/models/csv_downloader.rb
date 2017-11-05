require 'open-uri'

class CsvDownloader
  attr_reader :from_currency, :to_currency

  def initialize(from_currency: 'USD', to_currency: 'EUR')
    @from_currency = from_currency
    @to_currency = to_currency
  end

  def download
    begin
      File.open("exchange_rates/#{Rails.env}/exchange_rates.csv", "wb") do |file|
        file.write open(download_url).read
      end
    rescue => ex
      Rails.logger.error ex.message
      false
    end
  end

  private

  def download_url
    "http://sdw.ecb.europa.eu/quickviewexport.do?SERIES_KEY=120.EXR.D.#{from_currency}.#{to_currency}.SP00.A&type=csv"
  end
end