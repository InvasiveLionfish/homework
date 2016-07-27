require 'csv'
require 'pry'

class Slcsp
  def initialize 
    @zips = []
    @common_zip_areas = {}
    @common_rate_areas = {}
    @slcsp_rates = {}
  end 

  def get_zips
    CSV.foreach('slcsp.csv', headers: true) do |row|
      @zips << row["zipcode"]
    end
  end

  def get_rate_areas
    CSV.foreach('zips.csv', headers:true) do |row|
      zip = row["zipcode"]
      if @zips.include?(zip)
        @common_rate_areas = { state: row["state"], rate_area: row["rate_area"]}
      elsif @common_zip_areas.has_key?(zip) && @common_zip_areas[zip] != @common_rate_areas
        @common_zip_areas[zip] = nil
      else
        @common_zip_areas[zip] = @common_rate_areas
      end
    end
    @common_zip_areas.delete_if {|k,v| v.nil?}
  end

  def get_rates
    @common_zip_areas.each do |zip, rate_area|
      rates=[]
    CSV.foreach('plans.csv', headers:true) do |row|
          if row['state'] == rate_area[:state] && row['rate_area'] == rate_area[:rate_area] && row['metal_level'] == 'Silver'
        rates << row['rate'].to_f
          end
        end
    rates.sort!
    @slcsp_rates[zip] = rates[1]
  end

    CSV.open('slcsp_modified.csv', 'w', headers: true) do |rows|
    rows << ['zipcode', 'rate']
    @zips.each do |zip|
      rows << [zip, @slcsp_rates[zip]]
    end
   end
  end 

end

s = Slcsp.new
s.get_zips
s.get_rate_areas
s.get_rates


