class StkPushController < ApplicationController

def initiate_stk_push 
    api_url = 'https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials'

    consumer_key = ENV['CONSUMER_KEY']
    consumer_secret = ENV['CONSUMER_SECRET']
    shortcode = ENV['SHORT_CODE']
    callback_url= "https://captive-portal5.onrender.com/stk_push"   
    # "https://captive-portal5.onrender.com/stk_push" 
    lipa_na_mpesa_online_passkey =  ENV['PASS_KEY'];
    
     phone_number = params[:phone_number] 
    formatted_phone_number = "254#{phone_number.gsub(/\A0/, '')}"

    permitted_params = params.permit(:amount, :phone_number) 
    amount = params[:amount] 

    Rails.logger.info("Received parameters: #{params}")





   token = fetch_access_token(api_url,consumer_key, consumer_secret)
   

   if token
    response = initiate_payment(api_url, token, shortcode, lipa_na_mpesa_online_passkey, callback_url, phone_number, amount)
    render json: response
  else
    render json: { error: 'Failed to fetch access token' }, status: :unprocessable_entity
  end


end

private

  def fetch_access_token(api_url, consumer_key, consumer_secret)
    
    response = RestClient.get(api_url, { params: { grant_type: 'client_credentials' }, Authorization: "Basic #{Base64.strict_encode64("#{consumer_key}:#{consumer_secret}")}" })

    body = response.body
    Rails.logger.info("OAuth Response Body: #{body}")
    access_token = JSON.parse(response.body)['access_token']

access_token
  rescue RestClient::ExceptionWithResponse => e
    Rails.logger.error("Error fetching access token: #{e.response}")
    nil
  end



  def initiate_payment(api_url, token, shortcode, lipa_na_mpesa_online_passkey, callback_url, phone_number, amount)
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
  api_url2 = "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
    password = Base64.strict_encode64("#{shortcode}#{lipa_na_mpesa_online_passkey}#{timestamp}")


    Rails.logger.info("Payment Request Timestamp: #{timestamp}")
    Rails.logger.info("Payment Request Password: #{password}")

  payload = {    
    BusinessShortCode:shortcode,    
    Password:  password,    
    Timestamp:timestamp,    
    TransactionType: "CustomerPayBillOnline",    
    Amount: amount,    
    PartyA: phone_number,    
    PartyB:shortcode ,    
    PhoneNumber:phone_number,     
    CallBackURL: callback_url,    
    AccountReference:"Account",    
    TransactionDesc:"Making payment to captive-portal"
 }

 Rails.logger.info("Payment Request Payload: #{payload}")

 response = RestClient.post(
    api_url2,
    payload.to_json,
    { content_type: :json, Authorization: "Bearer #{token}" }
  )

  JSON.parse(response.body)
rescue RestClient::ExceptionWithResponse => e
  Rails.logger.error("Error initiating payment: #{e.response}")
  { error: 'Failed to initiate payment' }

  end

end
