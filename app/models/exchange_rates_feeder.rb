class ExchangeRatesFeeder
  attr_accessor :from_currency, :to_currency

  def initialize(from_currency: 'USD', to_currency: 'EUR')
    @from_currency = from_currency
    @to_currency = to_currency
  end

  def feed!
    download_csv_file && parse_csv!
  ensure
    delete_csv!
  end

  #######
  private
  #######

  def download_csv_file
    downloader = CsvDownloader.new
    downloader.download
  end

  def parse_csv!
    parser = CsvParser.new(from_currency: from_currency, to_currency: to_currency)
    parser.parse
  end

  def delete_csv!
    File.delete("exchange_rates/#{Rails.env}/exchange_rates.csv") if File.exist?("exchange_rates/#{Rails.env}/exchange_rates.csv")
  end
end