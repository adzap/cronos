require File.dirname(__FILE__) + '/spec_helper'

describe Cronos::Interval do
  it "should generate '0 * * * *' for 'hourly'" do
    interval.hourly.to_s.should  == '0 * * * *'
  end

  it "should generate '0 0 * * *' for 'daily'" do
    interval.daily.to_s.should  == '0 0 * * *'
  end

  it "should generate '0 8 * * *' for 'daily.at(8)'" do
    interval.daily.at(8).to_s.should  == '0 8 * * *'
  end

  it "should generate '21 8 * * *' for 'daily.at(8.21)'" do
    interval.daily.at(8.21).to_s.should  == '21 8 * * *'
  end
  
  it "should generate '0 0 * * 0' for 'weekly'" do
    interval.weekly.to_s.should  == '0 0 * * 0'
  end

  it "should generate '30 3 * * 0' for 'weekly.at(3.30)'" do
    interval.weekly.at(3.30).to_s.should  == '30 3 * * 0'
  end

  it "should generate '0 0 1 * *' for 'monthly'" do
    interval.monthly.to_s.should  == '0 0 1 * *'
  end

  it "should generate '30 3 * * *' for 'monthly.at(3.30)'" do
    interval.monthly.at(3.30).to_s.should  == '30 3 1 * *'
  end

  it "should generate '30 3 15 * *' for 'monthly.on_the('15th).at(3.30)'" do
    interval.monthly.on_the('15th').at(3.30).to_s.should  == '30 3 15 * *'
  end

  it "should generate '* * * * 1-5' for 'weekdays'" do
    interval.weekdays.to_s.should  == '* * * * 1-5'
  end
  
  it "should generate '* * * * 0,6' for 'weekends'" do
    interval.weekends.to_s.should  == '* * * * 0,6'
  end

  it "should generate '0,10,20,30,40,50 * * * *' for 'every(10).minutes'" do
    interval.every(10).minutes.to_s.should  == '0,10,20,30,40,50 * * * *'
  end
 
  it "should generate '0 0,6,12,18 * * *' for 'every(6).hours'" do
    interval.every(6).hours.to_s.should  == '0 0,6,12,18 * * *'
  end

  it "should generate '0 0 1 1,4,7,10 *' for 'every(3).months'" do
    interval.every(3).months.to_s.should  == '0 0 1 1,4,7,10 *'
  end

  it "should generate '0 12 * * 1,2' for 'at(12).pm.on_days(:monday, :tuesday)'" do
    interval.at(12).pm.on_days(:monday, :tuesday).to_s.should  == '0 12 * * 1,2'
  end

  it "should generate '* * 15 1 *' for 'on(15).of(:january)'" do
    interval.on(15).of(:january).to_s.should  == '* * 15 1 *'
  end

  it "should generate '* * 15,16,17 1 *' for 'on(15, 16, 17).of(:january)'" do
    interval.on(15, 16, 17).of(:january).to_s.should  == '* * 15,16,17 1 *'
  end
  
  it "should generate '* * 15-17 1 *' for 'on(15..17).of(:january)'" do
    interval.on(15..17).of(:january).to_s.should  == '* * 15-17 1 *'
  end

  it "should generate '* * 15 1,6,12 *' for 'on(15, 16, 17).of(:january)'" do
    interval.on(15).of(:jan, :jun, :dec).to_s.should  == '* * 15 1,6,12 *'
  end
  
  it "should generate '12 13 15 1' for 'at(12.13).pm.on_the_('15th').of(:january)'" do
    interval.at(12.13).pm.on_the(15).of(:january).to_s.should  == '13 12 15 1 *'
  end
  
  it "should generate '0,15,30,45 * 15 1 *'" do
    interval.every(15).minutes.on_the('15th').of(:january).to_s.should  == '0,15,30,45 * 15 1 *'
  end

  def interval
    Cronos::Interval.new
  end
end
