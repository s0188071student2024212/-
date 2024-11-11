require 'net/http'
require 'json'
require 'uri'

class Delivery
    attr_reader :weight, :length, :width, :height, :from, :to, :distance, :price

    def initialize(weight, length, width, height, from, to)
        @weight = weight
        @length = length
        @width = width
        @height = height
        @from = from
        @to = to
        @distance = calculate_distance
        @price = calculate_price
    end
    def calculate_distance
        api_key = "iVJ1bwByAXHkKzmocD7BclsUGPLeavhus8SSO4rUo3VWDA7mLA7tMWn6oQqmvXEp"  
        url = URI("https://api.distancematrix.ai/api/v1/distancematrix?origins=#{URI.encode_www_form(@from)}&destinations=#{URI.encode(@to)}&key=#{api_key}")

        begin
            response = Net::HTTP.get(url)
            data = JSON.parse(response)

        if data['status'] == 'OK' && data['rows'].any?
            distance_text = data['rows'][0]['elements'][0]['distance']['text']
            distance_text.split(' ')[0].to_f
        else
            0
        end
        rescue StandardError => e
            puts "Ошибка при запросе расстояния: #{e.message}"
            0
        end
    end

    def calculate_price
        size = (@length / 100.0) * (@width / 100.0) * (@height / 100.0)
        price_per_km = 0

        if size < 1
            price_per_km = 1
        elsif size > 1 && @weight <= 10
            price_per_km = 2
        elsif size > 1 && @weight > 10
            price_per_km = 3
        end
        price_per_km * @distance  
    end
    
    def to_hash
        {
            weight: @weight,
            length: @length,
            width: @width,
            height: @height,
            distance: @distance,
            price: @price
        }
    end
end

puts "Введите вес груза (кг): "
weight = gets.to_f

puts "Введите длину груза (см): "
length = gets.to_f

puts "Введите ширину груза (см): "
width = gets.to_f

puts "Введите высоту груза (см): "
height = gets.to_f

puts "Введите название пункта отправления: "
from = gets.chomp

puts "Введите название пункта назначения: "
to = gets.chomp

delivery = Delivery.new(weight, length, width, height, from, to)
puts delivery.to_hash
