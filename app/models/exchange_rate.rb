class ExchangeRate
  include Mongoid::Document

  field :from_currency, type: String
  field :to_currency, type: String
  field :rate, type: Float
  field :date, type: Date

  validates :from_currency, presence: true
  validates :to_currency,   presence: true
  validates :rate,          presence: true
  validates :date,          presence: true

  index({ date: 1          }, { name: "date_index"          })
  index({ from_currency: 1 }, { name: "from_currency_index" })
  index({ to_currency: 1   }, { name: "to_currency_index"   })
  index({ date: 1, from_currency:1, to_currency: 1 }, { unique: true, name: "date_and_currencies_index" })
end