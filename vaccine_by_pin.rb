# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'date'
require 'time'
require 'json'

pincode = 508001
date = Date.today
vaccine_types = ['COVISHIELD', 'COVAXIN'] # OR COVISHIELD
dose_number = 1
age = 30

play_sound = lambda do |center|
  time = Time.now
  system "say slots available at #{center}" while (time + 5) > Time.now # makes noise for a minute
end
base_url = "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByPin"
url = URI("#{base_url}?pincode=#{pincode}&date=#{date.strftime('%d-%m-%Y')}")
https = Net::HTTP.new(url.host, url.port)
https.use_ssl = true

request = Net::HTTP::Get.new(url)
response = https.request(request)
JSON.parse(response.body)['centers'].each do |center|
  center['sessions']&.each do |session|
    if session["available_capacity_dose#{dose_number}"].positive? &&
       vaccine_types.any? { |v| session['vaccine'] == v } &&
       session['min_age_limit'] <= age

      play_sound.call(center['name'])
    end
  end
end
