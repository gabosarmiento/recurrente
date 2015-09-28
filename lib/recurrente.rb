require "recurrente/version"
require "httparty"
require 'json'
require 'base64'

# TEST DATA
API_URL = "http://stg.api.payulatam.com/payments-api/rest/v4.3"
API_KEY = "6u39nqhq8ftd0hlvnjfs66eh8c"
API_LOGIN = "11959c415b33d0c"
MERCHANT_ID = "500238"
ACCOUNT = "500538"


module Recurrente
  include HTTParty 
  base_uri API_URL 
  headers = {
        'Content-type' => 'application/json;charset=UTF-8',
        'Accept' => 'application/json',
        'Accept-language' => 'es'
        }
  # No es necesario encodear con base64 ya que httparty lo hace por debajo
  basic_auth API_LOGIN, API_KEY
  default_timeout 4  # hard timeout after 4 seconds

  attr_accessor :auth
  @auth = "Basic " + Base64.encode64("#{API_LOGIN}:#{API_KEY}")
  # Una buena practica de consumir una API es definir los timeouts que podrían
  # acumularse y tumbar la pagina al tener los servidores atentidendo las peticiones
  # HTTParty sacará un Net::OpenTimeout si no puede conectarse al servidor y un 
  # Net::ReadTimeout si al leer la respuesta del servidor se cuelga.
 
  def self.handle_timeouts
    begin
      yield
    rescue Net::OpenTimeout, Net::ReadTimeout
      {}
    end
  end

   ########################################################################
  #                      ******  1 - PLANES  ******                       #
  #########################################################################
  # Mediante esta funcionalidad puedes crear el plan de pagos de una      # 
  #  una suscripción con las debidas restricciones y su recurrencia       #
  #########################################################################

  # 1.1 GET - Mostrar todos los planes
  def self.find_plans
    handle_timeouts do
      response = get("/plans")
      JSON.pretty_generate(response.parsed_response)
    end
  end
  
  # 1.2 POST - Crear un nuevo Plan
  def self.create_plan(codigo, descripcion, intervalo, cantidad_intervalos, moneda, valor, impuesto, base_impuesto, reintentos, dias_entre_reintentos, cobros,periodo_de_gracia)
      #######################################################################################################################
      # Recurrente.create_plan("Netflix-001", "Plan semanal", "WEEK", "1", "COP", "14000", "0", "0", "2", "2", "12", "2")   #
      # codigo                Es el nombre con el que se manipula el plan.                                                  #
      # descripcion           Es la descripción del Plan                                                                    #
      # intervalo             Es la frecuencia con la que se repite el cobro: DAY, WEEK, MONTH, YEAR.                       #
      # cantidad_intervalos   Es lo que define cada cuanto se realiza el cobro de la suscripción                            #  
      # moneda                Es el código para definir las divisas según el estándar internacional ISO 4217                #
      # valor                 Es el valor del plan                                                                          #
      # base_impuesto         Es el valor para calcular la devolución del impuesto                                          #
      # impuesto              Es el valor del impuesto                                                                      #
      # reintentos            Es la cantidad de intentos antes de ser rechazado el pago                                     #
      # cobros                Es la cantidad máxima de pagos que espera el plan                                             #
      # periodo de gracia     Es la cantidad máxima de pagos pendientes antes de cancelada                                  #
      # dias_entre_reintentos Es la cantidad de días de espera entre los reintentos.                                        #
      #######################################################################################################################  

    handle_timeouts do
      headers = {
          'Content-type' => 'application/json;charset=UTF-8',
          'Accept' => 'application/json',
          'Accept-language' => 'es', 
          'Authorization' => @auth 
          }
      params = {
         "accountId": ACCOUNT,
         "planCode": codigo,
         "description": descripcion,
         "interval": intervalo,
         "intervalCount": cantidad_intervalos ,
         "maxPaymentsAllowed": cobros,
         "paymentAttemptsDelay": dias_entre_reintentos,
         "maxPaymentAttempts": reintentos,
         "maxPendingPayments": periodo_de_gracia,
         "additionalValues": [
            {
               "name": "PLAN_VALUE",
               "value": valor,
               "currency": moneda
            },
            {
               "name": "PLAN_TAX",
               "value": impuesto,
               "currency": moneda
            },
            {
               "name": "PLAN_TAX_RETURN_BASE",
               "value": base_impuesto,
               "currency": moneda
            }
          ]
        }
      # Es necesario incluir los encabezados de otra forma lo identifica de otro typo distinto a json
      
      
      response = post("/plans", body: params.to_json, headers: headers)
      
      case response.code 
        when 200..202
          puts JSON.pretty_generate(response.parsed_response)
          retrieve_plan response
        when 404
          response.message
        when 500..600
          puts "OMG ERROR #{response.code}"
        else
          response
      end
    end # <-- Timeout Block
  end

  # 1.3 Consultar un plan existente 
  def self.find_plan(plan_code)
    handle_timeouts do
      response = get("/plans" + "/#{plan_code}")
      puts JSON.pretty_generate(response.parsed_response)
      response
    end
  end

  # 1.4 PUT - Actualizar un plan existente

  def self.update_plan(plan_code, codigo, descripcion, valor, impuesto, base_impuesto, reintentos, periodo_de_gracia, dias_entre_reintentos)
    # Atributos eliminados cuenta, intervalo, cantidad de intervalos, cobros, moneda 
    handle_timeouts do
      headers = {
          'Content-type' => 'application/json;charset=UTF-8',
          'Accept' => 'application/json',
          'Accept-language' => 'es', 
          'Authorization' => @auth
          }
      params = {
         "planCode": codigo,
         "description": descripcion,
         "paymentAttemptsDelay": dias_entre_reintentos,
         "maxPaymentAttempts": reintentos,
         "maxPendingPayments": periodo_de_gracia,
         "additionalValues": [
            {
               "name": "PLAN_VALUE",
               "value": valor
            },
            {
               "name": "PLAN_TAX",
               "value": impuesto
            },
            {
               "name": "PLAN_TAX_RETURN_BASE",
               "value": base_impuesto
            }
          ]
        }
      # Es necesario incluir los encabezados de otra forma lo identifica de otro typo distinto a json
      
      
      response = put("/plans" + "/#{plan_code}", body: params.to_json, headers: headers)
    
    
      case response.code 
        when 200..202
          puts JSON.pretty_generate(response.parsed_response)
          retrieve_plan response
        when 404
          response.message
        when 500..600
          puts "OMG ERROR #{response.code}"
        else
          response
      end
    end # <-- Timeout block
  end

  # 1.5 DELETE - Borrar un Plan existente

  def self.delete_plan(plan_code)
    handle_timeouts do
      response = delete("/plans" + "/#{plan_code}")   
    end
  end

  #####################################################################
  #               ******  2 - SUSCRIPTORES  ******                    #
  #####################################################################
  # Un cliente es la unidad que identifica quien será el beneficiario #
  # de un producto o servicio prestado y que se encuentra asociado a  #
  # un plan de pagos recurrentes.                                     #
  #####################################################################  
  
  # 2.1 POST - Crear un Suscriptor
  def self.create_suscriptor(name,email)
    handle_timeouts do
      headers = {
        'Content-type' => 'application/json;charset=UTF-8',
        'Accept' => 'application/json',
        'Accept-language' => 'es', 
        'Authorization' => @auth
        }
    
      params = {
         "fullName": name,
          "email": email
      }
    
      response = post('/customers', body: params.to_json, headers: headers)
     
      case response.code 
        when 200..202
          puts response
          puts JSON.pretty_generate(response.parsed_response)
          retrieve_customer response
        when 404
          response.message
        when 500..600
          puts "OMG ERROR #{response.code}"
        else
          response
      end
    end
  end

  # 2.2 GET - Buscar un Suscriptor 
  def self.find_suscriptor(customer_id)
    handle_timeouts do
      response = get("/customers" + "/#{customer_id}")
      
       case response.code 
        when 200..202
          puts JSON.pretty_generate(response.parsed_response)
          response.parsed_response["customer"] # Retorna el hash del suscriptor
        when 404
          response.message
        when 500..600
          puts "OMG ERROR #{response.code}"
        else
          response
      end
    end
  end

  # 2.3 PUT - Actualizar un Suscriptor
  def self.update_suscriptor(customer_id,name,email)
    handle_timeouts do
      headers = {
        'Content-type' => 'application/json;charset=UTF-8',
        'Accept' => 'application/json',
        'Accept-language' => 'es', 
        'Authorization' => @auth
        }
    
      params = {
         "fullName": name,
          "email": email
      }
    
      response = put('/customers'+ "/#{customer_id}", body: params.to_json, headers: headers)
      
      
      case response.code 
        when 200..202
          puts JSON.pretty_generate(response.parsed_response)
          retrieve_customer response
        when 404
          response.message
        when 500..600
          puts "OMG ERROR #{response.code}"
        else
          response
      end
    end
  end
  # 2.4 DELETE - Borrar un Suscriptor
  def self.delete_suscriptor(customer_id)
    handle_timeouts do
      response = delete("/customers" + "/#{customer_id}")
       case response.code 
        when 200..202
          puts response
          response.parsed_response["response"]["description"]
        when 404
          response.message
        when 500..600
          puts "OMG ERROR #{response.code}"
        else
          response
        end
    end
  end

  #########################################################################
  #             ******  3 - TARJETAS DE CREDITO  ******                   #
  #########################################################################
  # Es el medio de pago con el cual se relaciona un Plan y un Pagador,    # 
  # se encuentra compuesto por el número de tarjeta de crédito            #
  # (el cual será tokenizado para almacenar los datos de forma segura),   #
  # la fecha de vencimiento de la tarjeta y algunos datos adicionales     #
  # de dirección.                                                         #
  ######################################################################### 

  # 3.1 POST - Crear una Tarjeta de Credito a un Cliente
  
  def self.create_card(customer_id, numero , exp_mes, exp_ano ,tipo, nombre, documento, dir_linea1, dir_linea2 , dir_linea3 , departamento, ciudad, pais, codigo_postal, telefono)
    # Recurrente.add_customer_card(cliente, "371449635398431","01", "2018","AMEX","Pablo Picasso","1020304050","Calle Falsa","123","Patio 1","Bogotá","Bogotá D.C.", "CO", "110221", "3103456789")

    #############################################################################################################
    # customer_id           Campo para la URL no va en la petición. Código de identificación del cliente.       #
    # numero                Número de la tarjeta Ej: "4242424242424242"                                         #
    # exp_mes               Mes de expiración - Mínimo 1 máximo 12. Ej: "01"                                    #
    # exp_ano               Año de expiración de la tarjeta. Ej: "2018"                                         #
    # tipo                  Franquicia de la tarjeta VISA, AMEX, DINERS, MASTERCARD. Ej: "VISA"                 #
    # nombre                Nombre del tarjeta habiente: Ej: "Pedrito Fernandez"                                #
    # documento             Documento de identificación. Ej: "1020304050"                                       #
    # dir_linea1            Línea 1 de dirección opcional de correspondencia. Ej: "Calle Falsa"                 #
    # dir_linea2            Línea 2 de dirección opcional de correspondencia. Ej: "123"                         #
    # dir_linea3            Línea 3 de dirección opcional de correspondencia. Ej: "Patio trasero"               #
    # departamento          Nombre de departamento. Ej: "Bogotá"                                                #
    # ciudad                Nombre de ciudad. Ej: "Bogotá D.C."                                                 #
    # pais                  Dos letras del país según el Código ISO 3166. Ej: "CO"                              #
    # codigo_postal         Código de la dirección                                                              #
    # telefono              Teléfono asociado con la dirección                                                  #
    #############################################################################################################  
    handle_timeouts do
      headers = {
        'Content-Type' => 'application/json; charset=UTF-8',
        'Accept' => "application/json",
        'Accept-language' => 'es', 
        'Authorization' => @auth
        }
      params = {
           "name": nombre,
           "document": documento,
           "number": numero,
           "expMonth": exp_mes,
           "expYear": exp_ano,
           "type": tipo,
           "address": {
              "line1": dir_linea1,
              "line2": dir_linea2,
              "line3": dir_linea3,
              "postalCode": codigo_postal,
              "city": ciudad,
              "state": departamento,
              "country": pais,
              "phone": telefono
           }
        }

      response = post('/customers' + "/#{customer_id}/creditCards", body: JSON.generate(params), headers: headers)
      case response.code 
        when 200
          response
        when 201
          puts JSON.pretty_generate(response.parsed_response)
          retrieve_credit_card response
        when 404
          response.message
        when 500..600
          puts "OMG ERROR #{response.code}"
        else
          response
      end
    end 
  end

  # 3.2 GET - Buscar una tarjeta de crédito 
  def self.find_card(token)
    handle_timeouts do
      response = get("/creditCards" + "/#{token}")
      puts JSON.pretty_generate(response.parsed_response)
      case response.code 
        when 200
          response.parsed_response["creditCard"]
        else
          response
      end
    end
  end

  # 3.3 GET - Buscar tarjetas de crédito de un usuario 

  def self.find_cards_by_suscriptor(customer_id)
    handle_timeouts do
      response = get("/customers"+ "/#{customer_id}/creditCards")
       case response.code 
        when 200
          puts JSON.pretty_generate(response.parsed_response)
          response.parsed_response["creditCardListResponse"]["creditCards"]["creditCard"]
          # Retorna el hash de las tarjetas de crédito
        when 404
          response.message
        when 500..600
          puts "OMG ERROR #{response.code}"
        else
          response
      end
    end
  end

  # 3.4 DELETE - Eliminar una tarjeta de crédito 

  def self.delete_card(customer_id, token)
    handle_timeouts do
      response = delete("/customers" + "/#{customer_id}" + '/creditCards' + "/#{token}")
   
      case response.code 
        when 200..202
          puts response
          response.parsed_response["response"]["description"]
          # Retorna la descripción
        when 404
          response.message
        when 500..600
          puts "OMG ERROR #{response.code}"
        else
          response
      end
    end
  end

  ###########################################################
  #           ******  4 - SUSCRIPCIONES  ******             #
  #  Una suscripción es la relación entre un plan de pagos, #
  #  un pagador y una tarjeta de crédito  y es el elemento  #
  #  con el que se controla la ejecución de los cobros      #
  #  correspondientes.                                      #
  ###########################################################
  
  # 4.1 POST - Crear suscripción

  #  quantity       Es la cantidad de Planes que adquiere con la suscripción
  #  installments   Es el número de cuotas en las que diferira cada pago
  #  trial_days     Son los días de prueba 
  #  

  #  4.1.1 CON TODOS LOS ELEMENTOS NUEVOS
  def self.create_suscription(params = {})
    handle_timeouts do
      
      headers = {
          'Content-type' => 'application/json;charset=UTF-8',
          'Accept' => 'application/json',
          'Accept-language' => 'es', 
          'Authorization' => @auth
          }
      response = post('/subscriptions', body: params.to_json, headers: headers) 
      case response.code 
          when 200..202
            puts response
            retrieve_suscription response
          when 404
            response.message
          when 500..600
            puts "OMG ERROR #{response.code}"
          else
            response
      end
    end   
  end



  # 4.1.2 CON TODOS LOS ELEMENTOS EXISTENTES

  def self.create_suscription_all_existent(customer_id, plan_code, token, quantity, installments, trial_days)
    #Recurrente.add_new_suscription(cliente,plan,token,1,1,0)
    handle_timeouts do
      params = {
           "quantity": quantity,
           "installments": installments,
           "trialDays": trial_days,
           "customer": {
              "id": customer_id,
              "creditCards": [
                 {
                    "token": token
                 }
              ]
           },
           "plan": {
              "planCode": plan_code
           }
        }
      headers = {
          'Content-type' => 'application/json;charset=UTF-8',
          'Accept' => 'application/json',
          'Accept-language' => 'es', 
          'Authorization' => @auth
          }
      response = post('/subscriptions', body: params.to_json, headers: headers) 
      case response.code 
          when 200..202
            puts response
            retrieve_suscription response
          when 404
            response.message
            response
          when 500..600
            puts "OMG ERROR #{response.code}"
          else
            response
      end
    end
  end

  # 4.1.3 PLAN Y SUSCRIPTOR YA CREADOS Y UNA TARJETA NUEVA
  def self.create_suscription_alternative_1(customer_id, plan_code, quantity, installments, trial_days, numero , exp_mes, exp_ano ,tipo, nombre, documento, dir_linea1, dir_linea2 , dir_linea3 , departamento, ciudad, pais, codigo_postal, telefono )
    handle_timeouts do  
      params = {
         "quantity": quantity,
         "installments": installments,
         "trialDays": trial_days,
         "customer": {
            "id": customer_id,
            "creditCards": [
               {
                 "name": nombre,
                 "document": documento,
                 "number": numero,
                 "expMonth": exp_mes,
                 "expYear": exp_ano,
                 "type": tipo,
                 "address": {
                    "line1": dir_linea1,
                    "line2": dir_linea2,
                    "line3": dir_linea3,
                    "postalCode": codigo_postal,
                    "city": ciudad,
                    "state": departamento,
                    "country": pais,
                    "phone": telefono
                 }
              }
            ]
         },
         "plan": {
            "planCode": plan_code
         }
      }
      headers = {
          'Content-type' => 'application/json;charset=UTF-8',
          'Accept' => 'application/json',
          'Accept-language' => 'es', 
          'Authorization' => @auth
          }
      response = post('/subscriptions', body: params.to_json, headers: headers) 
      case response.code 
          when 200..202
            puts response
            retrieve_suscription response
          when 404
            response.message
          when 500..600
            puts "OMG ERROR #{response.code}"
          else
            response
      end
    end
  end

  # 4.1.4 CLIENTE Y TARJETA YA CREADOS, CON PLAN NUEVO 
  def self.create_suscription_alternative_2(customer_id, plan_code, token, quantity, installments, trial_days, codigo, descripcion, intervalo, cantidad_intervalos, moneda, valor, impuesto, base_impuesto, reintentos, dias_entre_reintentos, cobros,periodo_de_gracia)
    handle_timeouts do
      params = {
         "installments": installments,
         "trialDays": trial_days,
         "customer": {
            "id": customer_id,
            "creditCards": [
               {
                  "token": token
               }
            ]
         },
         "plan": {
            "accountId": ACCOUNT,
            "planCode": codigo,
            "description": descripcion,
            "interval": intervalo,
            "intervalCount": cantidad_intervalos ,
            "maxPaymentsAllowed": cobros,
            "paymentAttemptsDelay": dias_entre_reintentos,
            "maxPaymentAttempts": reintentos,
            "maxPendingPayments": periodo_de_gracia,
            "additionalValues": [
              {
                 "name": "PLAN_VALUE",
                 "value": valor,
                 "currency": moneda
              },
              {
                 "name": "PLAN_TAX",
                 "value": impuesto,
                 "currency": moneda
              },
              {
                 "name": "PLAN_TAX_RETURN_BASE",
                 "value": base_impuesto,
                 "currency": moneda
              }
            ]
          }
      }
      headers = {
          'Content-type' => 'application/json;charset=UTF-8',
          'Accept' => 'application/json',
          'Accept-language' => 'es', 
          'Authorization' => @auth
          }
      response = post('/subscriptions', body: params.to_json, headers: headers) 
      case response.code 
          when 200..202
            puts response
            retrieve_suscription response
          when 404
            response.message
          when 500..600
            puts "OMG ERROR #{response.code}"
          else
            response
      end
    end
  end

  # 4.2 PUT - Update Suscription Credit Card

  def self.update_suscription_card(suscription_id, token)
    handle_timeouts do
      headers = {
        'Content-type' => 'application/json;charset=UTF-8',
        'Accept' => 'application/json',
        'Accept-language' => 'es', 
        'Authorization' => @auth
        }
      params = {
        "creditCardToken": token
      }
      response = put('/subscriptions'+ "/#{suscription_id}", body: params.to_json, headers: headers)
        
      case response.code 
        when 200..202
          puts JSON.pretty_generate(response.parsed_response)
          puts response.code.to_s +  " " + response.message
          response
        when 404
          response.message
        when 500..600
          puts "OMG ERROR #{response.code}"
        else
          response
      end
    end
  end

  # 4.3 GET - Buscar una Suscripción
  def self.find_suscription(suscription_id)
    handle_timeouts do
      response = get("/subscriptions" + "/#{suscription_id}")
      
       case response.code 
        when 200..202
          puts JSON.pretty_generate(response.parsed_response)
          puts response.code.to_s +  " " + response.message
          response
        when 404
          response.code.to_s +  " " + response.message
        when 500..600
          puts "OMG ERROR #{response.code}"
        else
          response
      end
    end
  end

  # 4.4 GET - Buscar las suscripciones de un Cliente
  def self.find_suscriptions_by_suscriptor(customer_id)
    handle_timeouts do
      response = get("/subscriptions" + "/?customerId=#{customer_id}")
      
       case response.code 
        when 200..202
          puts JSON.pretty_generate(response.parsed_response)
          puts response.code.to_s +  " " + response.message
          response.parsed_response["subscriptionsListResponse"]["subscriptions"]
        when 404
          response.message
        when 500..600
          puts "OMG ERROR #{response.code}"
        else
          response
      end
    end
  end

  # 4.5 POST - Cancelar una Suscripción. Status CANCELLED

  def self.cancel_suscription(suscription_id)
    handle_timeouts do
      response = delete("/subscriptions" + "/#{suscription_id}")
   
      case response.code 
        when 200..202
          puts response
          response.parsed_response["response"]["description"]
        when 404
          response.message
        when 500..600
          puts "OMG ERROR #{response.code}"
        else
          response
      end
    end
  end


  ########################################################################
  #        ******  5 - CARGOS ADICIONALES  ******                        #
  #  Un cargo puede ser un cobro adicional o un descuento realizado      #
  #  sobre el valor de uno de los pagos que conforman el plan de         #
  #  pagos recurrentes. Estos solo afectan el siguiente cobro pendiente  #
  #  y se ejecutan una única vez.                                        #
  ########################################################################

  # 5.1 POST - Crear un cargo adicional

  def self.create_charge(suscription_id, descripcion, valor, moneda, impuesto, base_impuesto )
    handle_timeouts do
      headers = {
        'Content-type' => 'application/json; charset=UTF-8',
        'Accept' => 'application/json',
        'Accept-language' => 'es', 
        'Authorization' => @auth
        }
      params = {
         "description": descripcion,
         "additionalValues": [
            {
               "name": "ITEM_VALUE",
               "value": valor,
               "currency": moneda
            },
            {
               "name": "ITEM_TAX",
               "value": impuesto,
               "currency": moneda
            },
            {
               "name": "ITEM_TAX_RETURN_BASE",
               "value": base_impuesto,
               "currency": moneda
            }
         ]
      }
      response = post("/subscriptions" + "/#{suscription_id}" + "/recurringBillItems", body: params.to_json, headers: headers)
      case response.code 
        when 200..202
          puts JSON.pretty_generate(response.parsed_response)
          retrieve_extra_charge response
        when 404
          response.message
        when 500..600
          puts "OMG ERROR #{response.code}"
        else
          response
      end
    end
  end

  # 5.2 PUT - Actualizar un cargo adicional

  def self.update_charge(extra_charge_id, descripcion, valor, moneda, impuesto, base_impuesto )
    handle_timeouts do
      params = {
       "description": descripcion,
       "additionalValues": [
          {
             "name": "ITEM_VALUE",
             "value": valor,
             "currency": moneda
          },
          {
             "name": "ITEM_TAX",
             "value": impuesto,
             "currency": moneda
          },
          {
             "name": "ITEM_TAX_RETURN_BASE",
             "value": base_impuesto,
             "currency": moneda
          }
       ]
      } 
    
      headers = {
        'Content-type' => 'application/json;charset=UTF-8',
        'Accept' => 'application/json',
        'Accept-language' => 'es', 
        'Authorization' => @auth
        }
      put("/recurringBillItems" + "/#{extra_charge_id}", body: params.to_json, headers: headers)
      case response.code 
        when 200..202
          puts JSON.pretty_generate(response.parsed_response)
          puts response.code.to_s +  " " + response.message
          response
        when 404
          response.message
        when 500..600
          puts "OMG ERROR #{response.code}"
        else
          response
      end
    end
  end

  # 5.3 GET - Buscar un Cargo Extra por ID
  def self.find_charge_by_id(charge_id)
    handle_timeouts do
      response = get("/recurringBillItems" + "/#{charge_id}")
      
       case response.code 
        when 200
          puts JSON.pretty_generate(response.parsed_response)
          puts response.code.to_s +  " " + response.message
          response.parsed_response["recurringBillItem"]
          # Retorna el cargo extra
        when 404
          response.message
          response
        when 500..600
          puts "OMG ERROR #{response.code}"
          response
        else
          response
      end
    end
  end

  # 5.5 GET - Buscar un Cargo Extra por Suscripcion
  def self.find_charge_by_suscription(suscription_id)
    handle_timeouts do
      response = get("/recurringBillItems" + "/?subscriptionId=#{suscription_id}")
      
       case response.code 
        when 200
          puts JSON.pretty_generate(response.parsed_response)
          puts response.code.to_s +  " " + response.message
          response.parsed_response["recurringBillItemListResponse"]["recurringBillItems"]["recurringBillItem"]
          # Retorna los cargos extra de la suscripción
        when 404
          response.message
        when 500..600
          puts "OMG ERROR #{response.code}"
        else
          response
      end
    end
  end

  # 5.5 POST - Borrar un cargo de la suscripción

  def self.delete_charge(extra_charge_id)
    handle_timeouts do
      response = delete("/recurringBillItems" + "/#{extra_charge_id}")
   
      case response.code 
        when 200..202
          puts response
          puts response.code.to_s +  " " + response.message
          response.parsed_response["response"]["description"]
        when 404
          response.message
        when 500..600
          puts "OMG ERROR #{response.code}"
        else
          response
      end
    end
  end

  private
    def self.retrieve_plan(response)
      response.parsed_response["planCode"]
    end

    def self.retrieve_customer(response)
      response.parsed_response["id"]
    end

    def self.retrieve_credit_card(response)
      response.parsed_response["token"]
    end

    def self.retrieve_suscription(response)
      response.parsed_response["id"]
    end

    def self.retrieve_extra_charge(response)
      response.parsed_response["id"]
    end
end


