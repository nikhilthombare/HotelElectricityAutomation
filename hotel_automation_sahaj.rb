require 'rubygems'
require 'json'
require 'pry'

class HotelAutomate

  def initialize
    begin
      retries ||= 0
      @hotel_floors_array = []
      @floor_object = {"main_corridors" => {}, "sub_corridors" => {}}

      puts "Number of floors:"
      @number_of_floors = gets.chomp.to_i
      raise "Enter valid Number of floor" if @number_of_floors <= 0

      puts "Main corridors per floor:"
      @main_corridors = gets.chomp.to_i
      raise "Enter valid number of main corridor" if @main_corridors <= 0

      puts "Sub corridors per floor:"
      @sub_corridors = gets.chomp.to_i
      raise "Enter valid number of sub corridor" if @sub_corridors <= 0

    rescue Exception => e 
      puts "Error: #{e.message}"
      retry if (retries += 1) < 3
    end
  end
  
  def hotelActivity
    begin
      retries ||= 0
      puts "Movement in Floor:"
      floor_number = gets.chomp.to_i
      raise "Enter floor number less than #{@number_of_floors}" if @number_of_floors < floor_number

      puts "Movement in sub corridor number:"
      subcorridor_number = gets.chomp.to_i
      raise "Enter sub corridor number less than #{@sub_corridors}" if @sub_corridors < subcorridor_number

      updateState(floor_number, subcorridor_number)
    rescue Exception => e 
      puts "Error: #{e.message}"
      retry if (retries += 1) < 3
    end
  end

  def updateState(floor_number, subcorridor_number)
    array_index = floor_number - 1
    binding.pry
    puts array_index
    puts floor_number
    puts subcorridor_number
    puts @hotel_floors_array
      @hotel_floors_array[array_index][floor_number]['sub_corridors'][subcorridor_number]['light'] = "ON"
      # floor[floor_number]['sub_corridors'][subcorridor_number]["light"] = "ON" 
      # [floor_number]['sub_corridors'].each do |key, value|
      # @hotel_floors_array[array_index][floor_number]['sub_corridors'][1]["light"] = "ON" if key == subcorridor_number
    binding.pry
    printState
  end

  def defaultState
    # Total Floors
    (1..@number_of_floors).each do |floor|
      
      # Total Main Corridor
      (1..@main_corridors).each do |main_corridor|
        @floor_object['main_corridors'][main_corridor] = {"light" => "ON", "AC" => "ON" }
      end

      # Total Sub Corridor
      (1..@sub_corridors).each do |sub_corridor|
        @floor_object['sub_corridors'][sub_corridor] = {"light" => "OFF", "AC" => "ON" }
      end

      @hotel_floors_array.push(floor => @floor_object)
      
    end
    totalPowerConsumption

    printState
  end
  
  def totalPowerConsumption
    @hotel_floors_array.each do |floor|
      on_light_count = 0
      on_ac_count = 0

      floor_number = floor.keys[0]
      floor[floor_number]['main_corridors'].map{|k,v| on_light_count += 1 if v['light'] == "ON"}
      floor[floor_number]['main_corridors'].map{|k,v| on_ac_count += 1 if v['AC'] == "ON"}


      floor[floor_number]['sub_corridors'].map{|k,v| on_light_count += 1 if v['light'] == "ON"}
      floor[floor_number]['sub_corridors'].map{|k,v| on_ac_count += 1 if v['AC'] == "ON"}

      # light + AC total power required
      totalUsedPower = (on_light_count * 5) + (on_ac_count * 10)

      powerConsumptionCheck(@main_corridors, @sub_corridors, totalUsedPower)
    end  
  end

  def powerConsumptionCheck(main_corridor, sub_corridor, totalUsedPower)
    if ((main_corridor * 15) + (sub_corridor * 10)) <= totalUsedPower
      puts "---------min power"
    else
      puts "=========max power"
    end  
  end

  def printState
    @hotel_floors_array.each do |floor|
      floor_number = floor.keys[0]
      printFloor(floor_number)

      floor[floor_number]['main_corridors'].each do |key, value|
        printMainCorridor(floor_number, key, value)
      end
      floor[floor_number]['sub_corridors'].each do |key, value|
        printSubCorridor(floor_number, key,value)
      end
    end
  end

  def printFloor(floor_number)
    puts "\n\t\tFloor #{floor_number}"
  end

  def printMainCorridor(floor_number, key, value)
    puts "Main corridor #{key} Light #{key}: #{value['light']} AC: #{value['AC']}"
  end

  def printSubCorridor(floor_number, key, value)
    puts "Sub corridor #{key} Light #{key}: #{value['light']} AC: #{value['AC']}"
  end

 
end

hotel_object = HotelAutomate.new()

hotel_object.defaultState();

is_movement = 1
while is_movement == 1 do
  puts "Press 1 if movement on floor otherwise press 0 to exit"
  is_movement = gets.chomp.to_i
  if is_movement == 1
    hotel_object.hotelActivity();
  end  
end 


