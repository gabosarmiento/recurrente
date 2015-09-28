# Recurrente

This is a work in progress that seeks to explore the Payulatam's recurring payments api.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'recurrente'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install recurrente

## Usage

This is divided into 5 sections in the same way that is explained in Payu's website.

1. Plans
2. Suscriptors
3. Credit Cards
4. Suscriptions
5. Extra charges

Before anything you'll need to change the test data within an initializer in the config folder in order to replace these constants:

# TEST DATA
API_URL = "http://stg.api.payulatam.com/payments-api/rest/v4.3"
API_KEY = "6u39nqhq8ftd0hlvnjfs66eh8c"
API_LOGIN = "11959c415b33d0c"
MERCHANT_ID = "500238"
ACCOUNT = "500538"

Notice that the API_URL is pointing to http instead of using a secure protocol. This is just for testing purposes. 

## COVERED ENDPOINTS

  Everything is contained in the same ruby file because I wanted to see every method in one place. Clearly this needs improvement but so far this is what I got. 

  ### PLANS
   ####  1.1 GET - Mostrar todos los planes
   ####  1.2 POST - Crear un nuevo Plan
   ####  1.3 GET - Consultar un plan existente
   ####  1.4 PUT - Actualizar un plan existente
   ####  1.5 DELETE - Borrar un Plan existente

   ### SUSCRIPTORS
   ####  2.1 POST - Crear un Suscriptor
   #### 2.2 GET - Buscar un Suscriptor 
   #### 2.3 PUT - Actualizar un Suscriptor
   ####  2.4 DELETE - Borrar un Suscriptor

   ### CREDIT CARDS
   ####  3.1 POST - Crear una Tarjeta de Credito a un Suscriptor
   ####  3.2 GET - Buscar una tarjeta de crédito 
   ####  3.3 GET - Buscar tarjetas de crédito de un usuario 
   ####  3.4 DELETE - Eliminar una tarjeta de crédito 

   ### SUSCRIPTIONS
   ####  4.1 POST - Crear suscripción
   #####  4.1.1 CON TODOS LOS ELEMENTOS NUEVOS
   #####  4.1.2 CON TODOS LOS ELEMENTOS EXISTENTES
   #####  4.1.3 PLAN Y SUSCRIPTOR YA CREADOS Y UNA TARJETA NUEVA
   #####  4.1.4 CLIENTE Y TARJETA YA CREADOS, CON PLAN NUEVO 
   ####  4.2 PUT - Update Suscription Credit Card
   ####  4.3 GET - Buscar una Suscripción
   ####  4.4 GET - Buscar las suscripciones de un Cliente
   ####  4.5 POST - Cancelar una Suscripción. Status CANCELLED

   ### CHARGES
   ####  5.1 POST - Crear un cargo adicional
   ####  5.2 PUT - Actualizar un cargo adicional
   ####  5.3 GET - Buscar un Cargo Extra por ID
   ####  5.4 GET - Buscar un Cargo Extra por Suscripcion
   ####  5.5 POST - Borrar un cargo de la suscripción

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gabosarmiento/recurrente.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

