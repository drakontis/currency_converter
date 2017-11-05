require 'rails_helper'

describe ExchangeRateConverter do
  describe '#convert' do
    before do
      exchange_rate_1 = ExchangeRate.new(date: (Date.today - 5.day), from_currency: 'USD', to_currency: 'EUR', rate: 1.5)
      exchange_rate_1.save!
      exchange_rate_2 = ExchangeRate.new(date: (Date.today - 4.day), from_currency: 'USD', to_currency: 'EUR', rate: 1.4)
      exchange_rate_2.save!
      exchange_rate_3 = ExchangeRate.new(date: (Date.today - 3.day), from_currency: 'USD', to_currency: 'EUR', rate: 1.3)
      exchange_rate_3.save!
      exchange_rate_4 = ExchangeRate.new(date: (Date.today - 2.day), from_currency: 'USD', to_currency: 'EUR', rate: 1.2)
      exchange_rate_4.save!
    end

    context 'with future date' do
      it 'should raise error' do
        date_string = (Date.today + 1.day).to_s
        expect{ExchangeRateConverter.convert(2, date_string)}.to raise_error 'Invalid Date. Cannot convert for a date in future.'
      end
    end

    context 'without updated database' do
      it 'should return amount converted using the latest exchange rate' do
        date_string = (Date.today).to_s
        expect(ExchangeRateConverter.convert(2, date_string)).to eq 2/1.2
      end
    end

    context 'before 5 days' do
      it 'should return the converted amount' do
        date_string = (Date.today - 5.days).to_s
        expect(ExchangeRateConverter.convert(2, date_string)).to eq 2/1.5
      end
    end

    context 'before 4 days' do
      it 'should return the converted amount' do
        date_string = (Date.today - 4.days).to_s
        expect(ExchangeRateConverter.convert(2, date_string)).to eq 2/1.4
      end
    end

    context 'before 3 days' do
      it 'should return the converted amount' do
        date_string = (Date.today - 3.days).to_s
        expect(ExchangeRateConverter.convert(2, date_string)).to eq 2/1.3
      end
    end

    context 'before 2 days' do
      it 'should return the converted amount' do
        date_string = (Date.today - 2.days).to_s
        expect(ExchangeRateConverter.convert(2, date_string)).to eq 2/1.2
      end
    end
  end
end
