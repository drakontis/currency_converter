require 'rails_helper'

describe ExchangeRate do
  it { is_expected.to be_mongoid_document }

  describe 'Validations' do
    it { is_expected.to validate_presence_of :from_currency }
    it { is_expected.to validate_presence_of :to_currency   }
    it { is_expected.to validate_presence_of :rate          }
    it { is_expected.to validate_presence_of :date          }
  end

  describe 'indexes' do
    it{ is_expected.to have_index_for(date: 1).with_options(name: "date_index") }
    it{ is_expected.to have_index_for(from_currency: 1).with_options(name: "from_currency_index") }
    it{ is_expected.to have_index_for(to_currency: 1).with_options(name: "to_currency_index") }
    it{ is_expected.to have_index_for(date: 1, from_currency:1, to_currency: 1).with_options(unique: true, name: "date_and_currencies_index") }
  end

  describe '#new' do
    it 'should create a new exchange rate' do
      exchange_rate = ExchangeRate.new(from_currency: 'EUR', to_currency: 'USD', rate: 1.23, date: '2010-11-20')

      expect(exchange_rate).not_to be_persisted
      expect(exchange_rate.from_currency).to eq 'EUR'
      expect(exchange_rate.to_currency).to eq 'USD'
      expect(exchange_rate.rate).to eq 1.23
      expect(exchange_rate.date.to_s).to eq '2010-11-20'
    end
  end

  describe '#save' do
    it 'should save an exchange rate' do
      exchange_rate = ExchangeRate.new(from_currency: 'EUR', to_currency: 'USD', rate: 1.23, date: '2010-11-20')

      exchange_rate.save
      expect(exchange_rate).to be_persisted
      expect(exchange_rate.from_currency).to eq 'EUR'
      expect(exchange_rate.to_currency).to eq 'USD'
      expect(exchange_rate.rate).to eq 1.23
      expect(exchange_rate.date.to_s).to eq '2010-11-20'
    end
  end
end
