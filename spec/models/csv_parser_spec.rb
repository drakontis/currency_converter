require 'rails_helper'

describe CsvParser do
  describe '#initialize' do
    context 'with attributes' do
      it 'should create a new downloader' do
        parser = CsvParser.new(path_to_file: 'path/to/file', from_currency: 'NZD', to_currency: 'GBP')

        expect(parser).to be_a CsvParser
        expect(parser.path_to_file).to eq 'path/to/file'
        expect(parser.from_currency).to eq 'NZD'
        expect(parser.to_currency).to eq 'GBP'
      end
    end

    context 'without attributes' do
      it 'should create a new downloader' do
        parser = CsvParser.new

        expect(parser).to be_a CsvParser
        expect(parser.path_to_file).to eq 'exchange_rates/test/exchange_rates.csv'
        expect(parser.from_currency).to eq 'USD'
        expect(parser.to_currency).to eq 'EUR'
      end
    end
  end

  describe '#remove_entries_before!' do
    let(:csv){ [['2016-08-18', 1],
                ['2016-08-19', 2],
                ['2016-08-20', 3],
                ['2016-08-21', 4],
                ['2016-08-22', 5]] }

    it 'should remove entries before a date' do
      parser = CsvParser.new(path_to_file: 'path/to/file')
      parser.csv = csv

      parser.send(:remove_entries_before!, (Date.parse('2016-08-20')))

      expect(parser.csv).to be_an Array
      expect(parser.csv.size).to eq 3

      expect(parser.csv.first).to eq ['2016-08-20', 3]
      expect(parser.csv.second).to eq ['2016-08-21', 4]
      expect(parser.csv.third).to eq ['2016-08-22', 5]
    end
  end

  describe '#remove_headers' do
    let(:csv){ [['Data Source in SDW: null'],
                [nil, 'EXR.D.USD.EUR.SP00.A'],
                [nil, 'ECB reference exchange rate, US dollar/Euro, 2:15 pm (C.E.T.)'],
                ['Collection:', 'Average of observations through period (A)'],
                ['Period\\Unit:', '[US dollar ]'],
                ['2016-08-18', 1],
                ['2016-08-19', 2],
                ['2016-08-20', 3],
                ['2016-08-21', 4],
                ['2016-08-22', 5]] }

    it 'should remove the headers' do
      parser = CsvParser.new(path_to_file: 'path/to/file')
      parser.csv = csv

      parser.send(:remove_headers)

      expect(parser.csv).to be_an Array
      expect(parser.csv.size).to eq 5

      expect(parser.csv.first).to eq ['2016-08-18', 1]
      expect(parser.csv.second).to eq ['2016-08-19', 2]
      expect(parser.csv.third).to eq ['2016-08-20', 3]
      expect(parser.csv.fourth).to eq ['2016-08-21', 4]
      expect(parser.csv.fifth).to eq ['2016-08-22', 5]
    end
  end

  describe '#create_exchange_rate!' do
    it 'should create an exchange rate' do
      parser = CsvParser.new(path_to_file: 'path/to/file')

      expect do
        parser.send(:store_exchange_rate, date: '2012-12-14', rate: '1.23')
      end.to change{ ExchangeRate.count }.by 1

      exchange_rate = ExchangeRate.last
      exchange_rate.from_currency = 'USD'
      exchange_rate.to_currency = 'EUR'
      exchange_rate.date = Date.parse('2012-12-14')
      exchange_rate.rate = 1.23
    end
  end

  describe '#store_exchange_rates' do
    let(:csv){ [['1999-08-18', 1.01],
                ['1999-08-19', 1.02],
                ['1999-08-20', '-'],
                ['2000-01-04', 1.04],
                ['2000-01-06', 1.05],
                ['2000-01-08', 1.06],
                ['2000-01-11', '-']] }

    it 'should create the correct exchange rates' do
      parser = CsvParser.new(path_to_file: 'path/to/file')
      parser.csv = csv

      expect do
        parser.send(:store_exchange_rates)
      end.to change{ ExchangeRate.count }.by(11)

      exchange_rates = ExchangeRate.all
      expect(exchange_rates[0].from_currency).to eq 'USD'
      expect(exchange_rates[0].to_currency).to eq 'EUR'
      expect(exchange_rates[0].rate).to eq 1.02
      expect(exchange_rates[0].date).to eq Date.parse('2000-01-01')

      expect(exchange_rates[1].from_currency).to eq 'USD'
      expect(exchange_rates[1].to_currency).to eq 'EUR'
      expect(exchange_rates[1].rate).to eq 1.02
      expect(exchange_rates[1].date).to eq Date.parse('2000-01-02')

      expect(exchange_rates[2].from_currency).to eq 'USD'
      expect(exchange_rates[2].to_currency).to eq 'EUR'
      expect(exchange_rates[2].rate).to eq 1.02
      expect(exchange_rates[2].date).to eq Date.parse('2000-01-03')

      expect(exchange_rates[3].from_currency).to eq 'USD'
      expect(exchange_rates[3].to_currency).to eq 'EUR'
      expect(exchange_rates[3].rate).to eq 1.04
      expect(exchange_rates[3].date).to eq Date.parse('2000-01-04')

      expect(exchange_rates[4].from_currency).to eq 'USD'
      expect(exchange_rates[4].to_currency).to eq 'EUR'
      expect(exchange_rates[4].rate).to eq 1.04
      expect(exchange_rates[4].date).to eq Date.parse('2000-01-05')

      expect(exchange_rates[5].from_currency).to eq 'USD'
      expect(exchange_rates[5].to_currency).to eq 'EUR'
      expect(exchange_rates[5].rate).to eq 1.05
      expect(exchange_rates[5].date).to eq Date.parse('2000-01-06')

      expect(exchange_rates[6].from_currency).to eq 'USD'
      expect(exchange_rates[6].to_currency).to eq 'EUR'
      expect(exchange_rates[6].rate).to eq 1.05
      expect(exchange_rates[6].date).to eq Date.parse('2000-01-07')

      expect(exchange_rates[7].from_currency).to eq 'USD'
      expect(exchange_rates[7].to_currency).to eq 'EUR'
      expect(exchange_rates[7].rate).to eq 1.06
      expect(exchange_rates[7].date).to eq Date.parse('2000-01-08')

      expect(exchange_rates[8].from_currency).to eq 'USD'
      expect(exchange_rates[8].to_currency).to eq 'EUR'
      expect(exchange_rates[8].rate).to eq 1.06
      expect(exchange_rates[8].date).to eq Date.parse('2000-01-09')

      expect(exchange_rates[9].from_currency).to eq 'USD'
      expect(exchange_rates[9].to_currency).to eq 'EUR'
      expect(exchange_rates[9].rate).to eq 1.06
      expect(exchange_rates[9].date).to eq Date.parse('2000-01-10')

      expect(exchange_rates[10].from_currency).to eq 'USD'
      expect(exchange_rates[10].to_currency).to eq 'EUR'
      expect(exchange_rates[10].rate).to eq 1.06
      expect(exchange_rates[10].date).to eq Date.parse('2000-01-11')
    end

    it 'should create exchange rates only for new dates' do
      parser = CsvParser.new(path_to_file: 'path/to/file')
      parser.csv = csv

      expect do
        parser.send(:store_exchange_rates)
      end.to change{ ExchangeRate.count }.by(11)

      csv = [['1999-08-18', 1.01],
             ['1999-08-19', 1.02],
             ['1999-08-20', '-'],
             ['2000-01-04', 1.04],
             ['2000-01-06', 1.05],
             ['2000-01-08', 1.06],
             ['2000-01-11', '-'],
             ['2000-01-13', '1.07'],
             ['2000-01-15', '1.08']]

      parser.csv = csv

      expect do
        parser.send(:store_exchange_rates)
      end.to change{ ExchangeRate.count }.by(4)

      exchange_rates = ExchangeRate.all
      expect(exchange_rates[0].from_currency).to eq 'USD'
      expect(exchange_rates[0].to_currency).to eq 'EUR'
      expect(exchange_rates[0].rate).to eq 1.02
      expect(exchange_rates[0].date).to eq Date.parse('2000-01-01')

      expect(exchange_rates[1].from_currency).to eq 'USD'
      expect(exchange_rates[1].to_currency).to eq 'EUR'
      expect(exchange_rates[1].rate).to eq 1.02
      expect(exchange_rates[1].date).to eq Date.parse('2000-01-02')

      expect(exchange_rates[2].from_currency).to eq 'USD'
      expect(exchange_rates[2].to_currency).to eq 'EUR'
      expect(exchange_rates[2].rate).to eq 1.02
      expect(exchange_rates[2].date).to eq Date.parse('2000-01-03')

      expect(exchange_rates[3].from_currency).to eq 'USD'
      expect(exchange_rates[3].to_currency).to eq 'EUR'
      expect(exchange_rates[3].rate).to eq 1.04
      expect(exchange_rates[3].date).to eq Date.parse('2000-01-04')

      expect(exchange_rates[4].from_currency).to eq 'USD'
      expect(exchange_rates[4].to_currency).to eq 'EUR'
      expect(exchange_rates[4].rate).to eq 1.04
      expect(exchange_rates[4].date).to eq Date.parse('2000-01-05')

      expect(exchange_rates[5].from_currency).to eq 'USD'
      expect(exchange_rates[5].to_currency).to eq 'EUR'
      expect(exchange_rates[5].rate).to eq 1.05
      expect(exchange_rates[5].date).to eq Date.parse('2000-01-06')

      expect(exchange_rates[6].from_currency).to eq 'USD'
      expect(exchange_rates[6].to_currency).to eq 'EUR'
      expect(exchange_rates[6].rate).to eq 1.05
      expect(exchange_rates[6].date).to eq Date.parse('2000-01-07')

      expect(exchange_rates[7].from_currency).to eq 'USD'
      expect(exchange_rates[7].to_currency).to eq 'EUR'
      expect(exchange_rates[7].rate).to eq 1.06
      expect(exchange_rates[7].date).to eq Date.parse('2000-01-08')

      expect(exchange_rates[8].from_currency).to eq 'USD'
      expect(exchange_rates[8].to_currency).to eq 'EUR'
      expect(exchange_rates[8].rate).to eq 1.06
      expect(exchange_rates[8].date).to eq Date.parse('2000-01-09')

      expect(exchange_rates[9].from_currency).to eq 'USD'
      expect(exchange_rates[9].to_currency).to eq 'EUR'
      expect(exchange_rates[9].rate).to eq 1.06
      expect(exchange_rates[9].date).to eq Date.parse('2000-01-10')

      expect(exchange_rates[10].from_currency).to eq 'USD'
      expect(exchange_rates[10].to_currency).to eq 'EUR'
      expect(exchange_rates[10].rate).to eq 1.06
      expect(exchange_rates[10].date).to eq Date.parse('2000-01-11')

      expect(exchange_rates[11].from_currency).to eq 'USD'
      expect(exchange_rates[11].to_currency).to eq 'EUR'
      expect(exchange_rates[11].rate).to eq 1.06
      expect(exchange_rates[11].date).to eq Date.parse('2000-01-12')

      expect(exchange_rates[12].from_currency).to eq 'USD'
      expect(exchange_rates[12].to_currency).to eq 'EUR'
      expect(exchange_rates[12].rate).to eq 1.07
      expect(exchange_rates[12].date).to eq Date.parse('2000-01-13')

      expect(exchange_rates[13].from_currency).to eq 'USD'
      expect(exchange_rates[13].to_currency).to eq 'EUR'
      expect(exchange_rates[13].rate).to eq 1.07
      expect(exchange_rates[13].date).to eq Date.parse('2000-01-14')

      expect(exchange_rates[14].from_currency).to eq 'USD'
      expect(exchange_rates[14].to_currency).to eq 'EUR'
      expect(exchange_rates[14].rate).to eq 1.08
      expect(exchange_rates[14].date).to eq Date.parse('2000-01-15')
    end

    it 'should update the existing exchange rates' do
      parser = CsvParser.new(path_to_file: 'path/to/file')
      parser.csv = csv

      expect do
        parser.send(:store_exchange_rates)
      end.to change{ ExchangeRate.count }.by(11)

      csv = [['1999-08-18', 1.01],
             ['1999-08-19', 1.02],
             ['1999-08-20', '-'],
             ['2000-01-04', 1.04],
             ['2000-01-06', 1.25],
             ['2000-01-08', 1.06],
             ['2000-01-11', '-'],
             ['2000-01-13', '1.07'],
             ['2000-01-15', '1.08']]

      parser.csv = csv

      expect do
        parser.send(:store_exchange_rates)
      end.to change{ ExchangeRate.count }.by(4)

      exchange_rates = ExchangeRate.all
      expect(exchange_rates[0].from_currency).to eq 'USD'
      expect(exchange_rates[0].to_currency).to eq 'EUR'
      expect(exchange_rates[0].rate).to eq 1.02
      expect(exchange_rates[0].date).to eq Date.parse('2000-01-01')

      expect(exchange_rates[1].from_currency).to eq 'USD'
      expect(exchange_rates[1].to_currency).to eq 'EUR'
      expect(exchange_rates[1].rate).to eq 1.02
      expect(exchange_rates[1].date).to eq Date.parse('2000-01-02')

      expect(exchange_rates[2].from_currency).to eq 'USD'
      expect(exchange_rates[2].to_currency).to eq 'EUR'
      expect(exchange_rates[2].rate).to eq 1.02
      expect(exchange_rates[2].date).to eq Date.parse('2000-01-03')

      expect(exchange_rates[3].from_currency).to eq 'USD'
      expect(exchange_rates[3].to_currency).to eq 'EUR'
      expect(exchange_rates[3].rate).to eq 1.04
      expect(exchange_rates[3].date).to eq Date.parse('2000-01-04')

      expect(exchange_rates[4].from_currency).to eq 'USD'
      expect(exchange_rates[4].to_currency).to eq 'EUR'
      expect(exchange_rates[4].rate).to eq 1.04
      expect(exchange_rates[4].date).to eq Date.parse('2000-01-05')

      expect(exchange_rates[5].from_currency).to eq 'USD'
      expect(exchange_rates[5].to_currency).to eq 'EUR'
      expect(exchange_rates[5].rate).to eq 1.25
      expect(exchange_rates[5].date).to eq Date.parse('2000-01-06')

      expect(exchange_rates[6].from_currency).to eq 'USD'
      expect(exchange_rates[6].to_currency).to eq 'EUR'
      expect(exchange_rates[6].rate).to eq 1.25
      expect(exchange_rates[6].date).to eq Date.parse('2000-01-07')

      expect(exchange_rates[7].from_currency).to eq 'USD'
      expect(exchange_rates[7].to_currency).to eq 'EUR'
      expect(exchange_rates[7].rate).to eq 1.06
      expect(exchange_rates[7].date).to eq Date.parse('2000-01-08')

      expect(exchange_rates[8].from_currency).to eq 'USD'
      expect(exchange_rates[8].to_currency).to eq 'EUR'
      expect(exchange_rates[8].rate).to eq 1.06
      expect(exchange_rates[8].date).to eq Date.parse('2000-01-09')

      expect(exchange_rates[9].from_currency).to eq 'USD'
      expect(exchange_rates[9].to_currency).to eq 'EUR'
      expect(exchange_rates[9].rate).to eq 1.06
      expect(exchange_rates[9].date).to eq Date.parse('2000-01-10')

      expect(exchange_rates[10].from_currency).to eq 'USD'
      expect(exchange_rates[10].to_currency).to eq 'EUR'
      expect(exchange_rates[10].rate).to eq 1.06
      expect(exchange_rates[10].date).to eq Date.parse('2000-01-11')

      expect(exchange_rates[11].from_currency).to eq 'USD'
      expect(exchange_rates[11].to_currency).to eq 'EUR'
      expect(exchange_rates[11].rate).to eq 1.06
      expect(exchange_rates[11].date).to eq Date.parse('2000-01-12')

      expect(exchange_rates[12].from_currency).to eq 'USD'
      expect(exchange_rates[12].to_currency).to eq 'EUR'
      expect(exchange_rates[12].rate).to eq 1.07
      expect(exchange_rates[12].date).to eq Date.parse('2000-01-13')

      expect(exchange_rates[13].from_currency).to eq 'USD'
      expect(exchange_rates[13].to_currency).to eq 'EUR'
      expect(exchange_rates[13].rate).to eq 1.07
      expect(exchange_rates[13].date).to eq Date.parse('2000-01-14')

      expect(exchange_rates[14].from_currency).to eq 'USD'
      expect(exchange_rates[14].to_currency).to eq 'EUR'
      expect(exchange_rates[14].rate).to eq 1.08
      expect(exchange_rates[14].date).to eq Date.parse('2000-01-15')
    end
  end

  describe '#parse' do
    it 'should store the exchange rates' do
      parser = CsvParser.new(path_to_file: 'spec/test_files/exchange_rates.csv')

      expect do
        parser.parse
      end.to change{ ExchangeRate.count }.by(7)

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
