require 'rails_helper'

describe ExchangeRatesFeeder do
  describe '#initialize' do
    context 'with attributes' do
      it 'should create a new feeder' do
        feeder = ExchangeRatesFeeder.new(from_currency: 'NZD', to_currency: 'GBP')

        expect(feeder).to be_an ExchangeRatesFeeder
        expect(feeder.from_currency).to eq 'NZD'
        expect(feeder.to_currency).to eq 'GBP'
      end
    end

    context 'without attributes' do
      it 'should create a new feeder' do
        feeder = ExchangeRatesFeeder.new

        expect(feeder).to be_an ExchangeRatesFeeder
        expect(feeder.from_currency).to eq 'USD'
        expect(feeder.to_currency).to eq 'EUR'
      end
    end
  end

  describe '#download_csv_file' do
    it 'should try to download the csv' do
      downloader = CsvDownloader.new

      expect(CsvDownloader).to receive(:new).and_return downloader
      expect(downloader).to receive(:download)

      subject.send(:download_csv_file)
    end
  end

  describe '#parse_csv!' do
    it 'should try to download the csv' do
      parser = CsvParser.new

      expect(CsvParser).to receive(:new).with(from_currency: subject.from_currency, to_currency: subject.to_currency).and_return parser
      expect(parser).to receive(:parse)

      subject.send(:parse_csv!)
    end
  end

  describe '#delete_csv!' do
    it 'should delete the csv file' do
      File.open('exchange_rates/test/exchange_rates.csv', 'wb') {|f| f.write("contents") }
      expect(File).to exist("exchange_rates/test/exchange_rates.csv")
      subject.send(:delete_csv!)
      expect(File).not_to exist("exchange_rates/test/exchange_rates.csv")
    end
  end

  describe '#feed!' do
    it 'should store the exchange rates' do
      allow_any_instance_of(CsvParser).to receive(:path_to_file).and_return 'spec/test_files/exchange_rates.csv'

      feeder = ExchangeRatesFeeder.new

      expect(feeder).to receive(:delete_csv!)

      expect do
        feeder.feed!
      end.to change{ExchangeRate.count}.by 7

      exchange_rates = ExchangeRate.all
      expect(exchange_rates[0].from_currency).to eq 'USD'
      expect(exchange_rates[0].to_currency).to eq 'EUR'
      expect(exchange_rates[0].rate).to eq 1.0046
      expect(exchange_rates[0].date).to eq Date.parse('2000-01-01')

      expect(exchange_rates[1].from_currency).to eq 'USD'
      expect(exchange_rates[1].to_currency).to eq 'EUR'
      expect(exchange_rates[1].rate).to eq 1.0046
      expect(exchange_rates[1].date).to eq Date.parse('2000-01-02')

      expect(exchange_rates[2].from_currency).to eq 'USD'
      expect(exchange_rates[2].to_currency).to eq 'EUR'
      expect(exchange_rates[2].rate).to eq 1.0090
      expect(exchange_rates[2].date).to eq Date.parse('2000-01-03')

      expect(exchange_rates[3].from_currency).to eq 'USD'
      expect(exchange_rates[3].to_currency).to eq 'EUR'
      expect(exchange_rates[3].rate).to eq 1.0305
      expect(exchange_rates[3].date).to eq Date.parse('2000-01-04')

      expect(exchange_rates[4].from_currency).to eq 'USD'
      expect(exchange_rates[4].to_currency).to eq 'EUR'
      expect(exchange_rates[4].rate).to eq 1.0368
      expect(exchange_rates[4].date).to eq Date.parse('2000-01-05')

      expect(exchange_rates[5].from_currency).to eq 'USD'
      expect(exchange_rates[5].to_currency).to eq 'EUR'
      expect(exchange_rates[5].rate).to eq 1.0388
      expect(exchange_rates[5].date).to eq Date.parse('2000-01-06')

      expect(exchange_rates[6].from_currency).to eq 'USD'
      expect(exchange_rates[6].to_currency).to eq 'EUR'
      expect(exchange_rates[6].rate).to eq 1.0284
      expect(exchange_rates[6].date).to eq Date.parse('2000-01-07')
    end
  end
end
