## Overview
This is a simple currency converter. It converts an amount from a currency to another for a given date, using the exchange rates from the European Central Bank(ECB).

The ECB does not provide exchange rates for weekends and holidays. To convert an amount from one currency to another for these days, we use the previously available exchange rate.


## Architecture
The application is consisted by 5 classes. Four of them are used to download and store the exchange rates and the other one is the currency converter.
The application has been designed to support more than one from-to currency pairs. You can use the application without specifing any *from* and *to* currencies. The default currency pair is:
* from_currency: USD
* to_currency: EUR 


Considering that the application supports more than one from-to currency pairs and that can result to a huge amount of data, I decided to use MongoDb as Datastore. This is possible due to the lack of object relations in the application. 

Using a no-sql database, the performance of the database queries is improved, making the response time of the application significantly small.
As I said before, the ECB does not provide exchange rates for weekends and holidays, therefore I use the previous available exchange rate for the calculations. 
In order to improve the exchange_rate_converter's performance, I decided to store in our Datastore the exchange rate for these days. 
By doing this, it doesn't have to search for previous available exchange rates, instead It has the desired exchange rate by just one query in the database.

When storing the exchange rate, I chose to iterate all the exchange rate entries in the CSV file instead of only the new ones. 
This is in order to update the entries that for any reason have a different exchange rate than before (bank changed the value in the CSV, someone changed the value in our database, etc) with the exchange rate in the current CSV file.

## Future improvements
In order to improve the performance of the exchange rates storing, we can split the process that updates the existing data in a separate rake task.   

## Usage
To run the application you should have the following software installed:
* MongoDB
  * [Installation Instructions](https://docs.mongodb.com/manual/installation/)
* RVM (Ruby Version Manager)
  * [Installation Instructions](https://rvm.io/rvm/install)
* Ruby v2.2.8
  * To Install ruby just type in a console:

```
rvm install ruby-2.2.8
```

When the required software is installed, visit the project’s root folder (if you are already there just type cd .) and type:

```
rvm current
```

You should see something like this:

```
ruby-2.3.5@currency_converter
```

Then you need to install the bundler gem. In the project’s root folder type:

```
gem install bundler
```

Now you are ready to install all the external libraries (gems). To do this in the project’s root folder type:

```
bundle install
```

(This could take a while.)

To create the database indexes, run:
```
rake db:mongoid:create_indexes
```

Create the necessary folders

```
mkdir exchange_rates
mkdir exchange_rates/test
mkdir exchange_rates/development
mkdir exchange_rates/production
```

To fetch and populate the database, run the following rake task:
```
rake exchange_rates:load[from_currency,to_currency]
```
The *from_currency* and *to_currency* arguments are optional. The default values are USD and EUR respectively.

Now you are ready to open a rails console. In the project’s root folder type:

```
rails c
```

To convert an amount from a currency to another, just type:

```
ExchangeRateConverter.convert(amount, date_string, from_currency, to_currency)
```
The from_currency and to_currency arguments are optional. The default values are USD and EUR respectively.

## Tests
The application is fully unit tested and it also includes some functional tests, to ensure that the integration between the application’s components is working.
To run the whole test suite, from the project’s root folder just type:

```
rspec spec
```

## License
The application is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
