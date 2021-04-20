require 'json'

class HotelAutomate

  def initialize(hotel_details)
    begin
      @number_of_floors = hotel_details['number_of_floors']
      @main_corridors = hotel_details['main_corridors_per_floor']
      @sub_corridors = hotel_details['sub_corridors_per_floor']
    rescue Exception => e 
      puts "Error: #{e.message}"
    end
  end

  def defaultState()
    hotel_floors_array = {}
    # Total Floors
    (1..@number_of_floors).each do |floor|
      floor_object = {'main_corridors' => {},'sub_corridors' => {}}
      
      # Total Main Corridor
      (1..@main_corridors).each do |main_corridor|
        floor_object['main_corridors'][main_corridor] = {"light" => "ON", "AC" => "ON" }
      end
      # Total Sub Corridor
      (1..@sub_corridors).each do |sub_corridor|
        floor_object['sub_corridors'][sub_corridor] = {"light" => "OFF", "AC" => "ON" }
      end

      hotel_floors_array[floor] = floor_object
    end
    totalPowerConsumption(hotel_floors_array)

    hotel_floors_array
  end
  
  def activityDetected(hotel_floors_details, floor_number, subcorridor_number)
    begin
      raise "Enter floor number less than #{@number_of_floors}" if @number_of_floors < floor_number
      raise "Enter sub corridor number less than #{@sub_corridors}" if @sub_corridors < subcorridor_number

      puts "\n-----Movement in Floor #{floor_number}, Sub corridor #{subcorridor_number}"

      hotel_floors_details[floor_number]['sub_corridors'][subcorridor_number]['light'] = "ON" 

      totalPowerConsumption(hotel_floors_details, subcorridor_number)
    rescue Exception => e 
      "Error: #{e.message}"
    end
  end

  def noActivityDetected(hotel_floors_details, floor_number, subcorridor_number)
    puts "\n-----No movement in Floor #{floor_number}, Sub corridor #{subcorridor_number} for a minute"
   
    hotel_floors_details.each do |floornumber, floor|
      if floornumber == floor_number
        floor['sub_corridors'].each do |number, corridor|
          corridor['light'] = "OFF"
          corridor['AC'] = "ON"
        end 
      end
      printState(floor, floor_number)
    end  
  end


  private

  def totalPowerConsumption(floors_details, subcorridor_number = nil)
    floors_details.each do |floor_number,floor|
      floorWisePowerConsumption(floors_details, floor_number, subcorridor_number)
    end  
  end

  def floorWisePowerConsumption(floors_details, floor_number, subcorridor_number = nil)
    floor = floors_details[floor_number]
    powerConsumptionCheck(floors_details, floor_number, powerConsumption(floor), subcorridor_number)
  end

  def powerConsumption(floor)
    on_light_count = 0
    on_ac_count = 0
    floor['main_corridors'].map{|k,v| on_light_count += 1 if v['light'] == "ON"}
    floor['main_corridors'].map{|k,v| on_ac_count += 1 if v['AC'] == "ON"}

    floor['sub_corridors'].map{|k,v| on_light_count += 1 if v['light'] == "ON"}
    floor['sub_corridors'].map{|k,v| on_ac_count += 1 if v['AC'] == "ON"}
    # light + AC total power count
    totalUsedPower = (on_light_count * 5) + (on_ac_count * 10)

    checkPowerConsumption(totalUsedPower)
  end

  def checkPowerConsumption(totalUsedPower)
    totalUsedPower <= ((@main_corridors * 15) + (@sub_corridors * 10))
  end

  def powerConsumptionCheck(floors_details, floor_number, is_power_consumption_less, subcorridor_number = nil)
    if is_power_consumption_less
      # puts "---floor--#{floor_number}----min power"
      printState(floors_details[floor_number], floor_number)
    else
      # puts "---floor--#{floor_number}----max power"
      powerConsumptionMode(floors_details, floor_number, subcorridor_number)
    end  
  end

  def powerConsumptionMode(floors_details, floor_number, subcorridor_number)
    floor = floors_details[floor_number]
    floors_details[floor_number]['sub_corridors'].each do |key, value|
      break if powerConsumption(floor)
      unless subcorridor_number == key 
        value['AC'] = 'OFF'
        floorWisePowerConsumption(floors_details, floor_number, subcorridor_number) 
      end  
    end
  end

  def printState(floor, floor_number)
    printFloor(floor_number)
    floor['main_corridors'].each do |key, value|
      printCorridor(key, value, 'Main')
    end

    floor['sub_corridors'].each do |key, value|
      printCorridor(key,value, 'Sub')
    end
  end

  def printFloor(floor_number)
    puts "\n\t\tFloor #{floor_number}"
  end

  def printCorridor(key, value, type)
    puts "#{type} corridor #{key} Light #{key}: #{value['light']} AC: #{value['AC']}"
  end
end
