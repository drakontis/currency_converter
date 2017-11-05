require 'rails_helper'

describe CsvDownloader do
  describe '#initialize' do

    context 'with attributes' do
      it 'should create a new downloader' do
        downloader = CsvDownloader.new(from_currency: 'GBP', to_currency: 'NZD')

        expect(downloader).to be_a CsvDownloader
        expect(downloader.from_currency).to eq 'GBP'
        expect(downloader.to_currency).to eq 'NZD'
      end
    end

    context 'without attributes' do
      it 'should create a new downloader' do
        downloader = CsvDownloader.new

        expect(downloader).to be_a CsvDownloader
        expect(downloader.from_currency).to eq 'USD'
        expect(downloader.to_currency).to eq 'EUR'
      end
    end
  end

  describe '#download' do
    let(:path_to_file) { 'exchange_rates/test/exchange_rates.csv' }
    subject { CsvDownloader.new(from_currency: 'NZD', to_currency: 'GBP') }

    before { File.delete(path_to_file) if File.exist?(path_to_file) }

    context 'success downloading' do
      it 'should download the csv file' do
        open_url_result = double('OpenUrlResult')
        result = 'Test Result'
        expect(subject).to receive(:open).with(subject.send(:download_url)).and_return open_url_result
        expect(open_url_result).to receive(:read).and_return result

        expect(subject.download).to be_truthy

        file = File.open(path_to_file)
        expect(file).not_to be_nil

        expect(file.read).to eq 'Test Result'
      end
    end

    context 'failed downloading' do
      it 'should log error' do
        expect(subject).to receive(:open).with(subject.send(:download_url)).and_raise RuntimeError.new('Test Runtime Error')

        expect(Rails).to receive_message_chain(:logger, :error).with('Test Runtime Error')
        expect(subject.download).to be_falsey
      end
    end

    after { File.delete(path_to_file) if File.exist?(path_to_file) }
  end

  describe '#download_url' do
    subject { CsvDownloader.new(from_currency: 'NZD', to_currency: 'GBP') }

    it 'should return a url' do
      expect(subject.send(:download_url)).to eq "http://sdw.ecb.europa.eu/quickviewexport.do?SERIES_KEY=120.EXR.D.#{subject.from_currency}.#{subject.to_currency}.SP00.A&type=csv"
    end
  end
end
