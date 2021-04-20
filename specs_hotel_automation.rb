require 'rspec'
require './hotel_automation'

describe "Hotel Automation" do
  let(:hotel_details) { JSON.parse(File.read("./hotel_mock_data.json")) }
  let(:floor_number) { 2 }
  let(:subcorridor_number) { 2 }
  let(:hotel_object) { HotelAutomate.new(hotel_details) }

  it "Passing invalid floor number" do
    details = hotel_object.defaultState();
    invalid_floor_number  = hotel_details['number_of_floors'] + 1
    response = hotel_object.activityDetected(details, invalid_floor_number, subcorridor_number);  
    expect(response).to include("Error: Enter floor number less than" )
  end

  it "Passing invalid sub corridor number" do
    details = hotel_object.defaultState();
    invalid_sub_corridors_number  = hotel_details['sub_corridors_per_floor'] + 1
    response = hotel_object.activityDetected(details, floor_number, invalid_sub_corridors_number);  
    expect(response).to include("Error: Enter sub corridor number less than" )
  end

  it "Movement happend on floor with valid data of floor and Sub corridor" do
    details = hotel_object.defaultState();
    response = hotel_object.activityDetected(details, floor_number, subcorridor_number);  
    expect(response[floor_number]['sub_corridors'][subcorridor_number]['light']).to eq("ON")
    expect(response[floor_number]['sub_corridors'][subcorridor_number]['AC']).to eq("ON")
  end

  it "No Movement on floor for a minute will set to defaultState" do
    details = hotel_object.defaultState();
    response = hotel_object.activityDetected(details, floor_number, subcorridor_number) 
    result = hotel_object.noActivityDetected(response, floor_number, subcorridor_number)

    result.each do |floor_number, floor|
      floor['sub_corridors'].each do |key, value|
        expect(value['light']).to eq("OFF")
        expect(value['AC']).to eq("ON")
      end
    end
  end

end