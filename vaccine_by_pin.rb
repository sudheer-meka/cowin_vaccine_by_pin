# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'date'
require 'time'
require 'json'

pincode = 500034
date = Date.today
vaccine_type = 'COVAXIN' # OR COVISHIELD
dose_number = 2
age_limit = 45

play_sound = lambda do
  time = Time.now
  system 'say book vaccine' while (time + 60) > Time.now # makes noise for a minute
end
base_url = "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByPin"
url = URI("#{base_url}?pincode=#{pincode}&date=#{date.strftime('%d-%m-%Y')}")
https = Net::HTTP.new(url.host, url.port)
https.use_ssl = true

request = Net::HTTP::Get.new(url)
response = https.request(request)
sessions = JSON.parse(response.body)['centers'].map { |c| c['sessions'] }.flatten
sessions&.find do |session|
  session["available_capacity_dose#{dose_number}"].positive? &&
    session['vaccine'] == vaccine_type &&
    session['min_age_limit'] == age_limit
end && play_sound.call
