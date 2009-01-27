require File.dirname(__FILE__) + '/spec_helper'

describe Cronos::Interval do

  it "should return default interval for every minute" do
    interval.to_s.should == '* * * * *'
  end

  it "should return hash of values from to_hash method" do
    interval.at(2.01).on_the('3rd').of(:april).to_hash.should == {:minute => '1', :hour => '2', :day => '3', :month => '4', :weekday => '*'}
  end

  describe "at method" do
    it "should output interval from integer with hour as integer value and 0 minute" do
      interval.at(8).to_s.should == '0 8 * * *'
    end

    it "should output interval from a float with hour value from integer part and minute from decimal part" do
      interval.at(8.21).to_s.should == '21 8 * * *'
    end
    
    it "should output interval from a float with hour value from integer part and minute from decimal part left justified to 2 digits" do
      interval.at(8.20).to_s.should == '20 8 * * *'
    end

    it "should output interval from time string with pm meridian having hour adjusted 24 hour time" do
      interval.at('8.21pm').to_s.should == '21 20 * * *'
    end
    
    it "should output interval from time string with pm meridian having hour unadjusted if hour is 12" do
      interval.at('12.21pm').to_s.should == '21 12 * * *'
    end

    it "should output interval from time string with am meridian having hour adjusted to 0 if hour is 12" do
      interval.at('12.21am').to_s.should == '21 0 * * *'
    end

    it "should raise error if hours out of range" do
      lambda { interval.daily.at('24.21') }.should raise_error
    end

    it "should raise error if minutes out of range" do
      lambda { interval.daily.at('23.60') }.should raise_error
    end
  end
  
  describe "on method" do
    it "should output interval from integer with day of month as value" do
      interval.on(15).to_s.should == '* * 15 * *'
    end

    it "should output interval from day string with ordinal suffix" do
      interval.on('15th').to_s.should == '* * 15 * *'
    end

    it "should output interval from inclusive range as dashed day of month range " do
      interval.on(15..17).to_s.should == '* * 15-17 * *'
    end
    
    it "should output interval from exclusive range as dashed day of month range " do
      interval.on(15...18).to_s.should == '* * 15-17 * *'
    end

    it "should output interval from integer array as day number list" do
      interval.on(15, 16, 17).to_s.should == '* * 15,16,17 * *'
    end

    it "should output interval from day string array as day number list" do
      interval.on('15th', '16th', '17th').to_s.should == '* * 15,16,17 * *'
    end
  end

  describe "of method" do
    it "should output interval with month number from a symbol month name" do
      interval.of(:january).to_s.should == '* * * 1 *'
    end

    it "should output interval with month number from a symbol short month name" do
      interval.of(:jan).to_s.should == '* * * 1 *'
    end

    it "should output interval with month number from a strong month name" do
      interval.of('January').to_s.should == '* * * 1 *'
    end

    it "should output interval with comma seperated month numbers from array of symbol month names" do
      interval.of(:january, :february, :march).to_s.should == '* * * 1,2,3 *'
    end

    it "should output interval with comma seperated month numbers from array of short symbol month names" do
      interval.of(:jan, :feb, :mar).to_s.should == '* * * 1,2,3 *'
    end

    it "should output interval with comma seperated month numbers from array of string month names" do
      interval.of('January', 'February', 'March').to_s.should == '* * * 1,2,3 *'
    end

    it "should output interval from integer inclusive range as dashed month range " do
      interval.of(1..3).to_s.should == '* * * 1-3 *'
    end

    it "should output interval from integer exclusive range as dashed month range " do
      interval.of(1...4).to_s.should == '* * * 1-3 *'
    end
  end

  describe "days method" do
    it "should output interval with day number from a symbol day name" do
      interval.days(:monday).to_s.should == '* * * * 1'
    end

    it "should output interval with day number from a string day name" do
      interval.days('Mondays').to_s.should == '* * * * 1'
    end

    it "should output interval with day number from a symbol short day name" do
      interval.days(:mon).to_s.should == '* * * * 1'
    end

    it "should output interval with day numbers from array of symbol day names" do
      interval.days(:monday, :wednesday, :friday).to_s.should == '* * * * 1,3,5'
    end

    it "should output interval with day numbers from array of symbol short day names" do
      interval.days(:mon, :wed, :fri).to_s.should == '* * * * 1,3,5'
    end

    it "should output interval with day numbers from array of string day names" do
      interval.days('Monday', 'Wednesday', 'Friday').to_s.should == '* * * * 1,3,5'
    end
  end

  describe "hourly method" do
    it "should output interval to run at start of every hour" do
      interval.hourly.to_s.should == '0 * * * *'
    end

    it "should only affect the hour and minutes" do
      interval.day = 1
      interval.month = 1
      interval.dow = 1
      interval.hourly.to_s.should == '0 * 1 1 1'
    end
  end

  describe "daily method" do
    it "should output interval to run at 00:00 every day by default" do
      interval.daily.to_s.should == '0 0 * * *'
    end

    it "should only affect the hour, minutes and day" do
      interval.month = 1
      interval.dow = 1
      interval.daily.to_s.should == '0 0 * 1 1'
    end

    it "should preserve hour and minutes if set" do
      interval.min = 10
      interval.hour = 11
      interval.daily.to_s.should == '10 11 * * *'
    end
  end

  describe "midnight method" do
    it "should output interval to run at 00:00" do
      interval.midnight.to_s.should == '0 0 * * *'
    end
  end

  describe "midday method" do
    it "should output interval to run at 12:00" do
      interval.midday.to_s.should == '0 12 * * *'
    end
  end

  describe "weekly method" do
    it "should output interval to run on Sunday at 00:00 by default" do
      interval.weekly.to_s.should == '0 0 * * 0'
    end

    it "should override day of month and month" do
      interval.day = 1
      interval.month = 1
      interval.weekly.to_s.should == '0 0 * * 0'
    end

    it "should preserve hour, minute and day of week if set" do
      interval.min = 10
      interval.hour = 11
      interval.dow = 1
      interval.daily.to_s.should == '10 11 * * 1'
    end
  end

  describe "monthly method" do
    it "should output interval to run on the 1st day of every month at 00:00 by default" do
      interval.monthly.to_s.should == '0 0 1 * *'
    end

    it "should override day of month and month" do
      interval.day = 1
      interval.month = 1
      interval.monthly.to_s.should == '0 0 1 * *'
    end

    it "should preserve hour, minute and day if set" do
      interval.min = 10
      interval.hour = 11
      interval.day = 12
      interval.monthly.to_s.should == '10 11 12 * *'
    end
  end

  describe "weekends method" do
    it "should output interval to run at 00:00 every Saturday and Sunday" do
      interval.weekends.to_s.should == '0 0 * * 0,6'
    end
  end

  describe "weekdays method" do
    it "should output interval to run at 00:00 every day Monday to Friday" do
      interval.weekdays.to_s.should == '0 0 * * 1-5'
    end
  end

  describe "every(x).minutes" do
    it "should output interval for list of minutes differing by arg value" do
      interval.every(15).minutes.to_s.should == '0,15,30,45 * * * *'
    end

    it "should raise error if x not a divisor of 60" do
      lambda { interval.every(13).minutes }.should raise_error
    end
  end

  describe "every(x).hours" do
    it "should output interval for 0 minute and list of hours differing by arg value" do
      interval.every(6).hours.to_s.should == '0 0,6,12,18 * * *'
    end

    it "should raise error if x not a divisor of 24" do
      lambda { interval.every(13).minutes }.should raise_error
    end
  end

  describe "every(x).months" do
    it "should output interval for 00:00 on 1st day of month and list of months differing by arg value" do
      interval.every(6).hours.to_s.should == '0 0,6,12,18 * * *'
    end

    it "should raise error if x not a divisor of 12" do
      lambda { interval.every(7).minutes }.should raise_error
    end
  end
  
  describe "combinations" do
    it "weekly.at(3.30) should output '30 3 * * 0'" do
      interval.weekly.at(3.30).to_s.should == '30 3 * * 0'
    end

    it "monthly.at(3.30) should output '30 3 * * *'" do
      interval.monthly.at(3.30).to_s.should == '30 3 1 * *'
    end

    it "monthly.on_the('15th').at(3.30) should output '30 3 15 * *'" do
      interval.monthly.on_the('15th').at(3.30).to_s.should == '30 3 15 * *'
    end

    it "at('11pm').on_days(:monday, :tuesday) should output '0 11 * * 1,2'" do
      interval.at('11pm').on_days(:monday, :tuesday).to_s.should == '0 23 * * 1,2'
    end

    it "on(15).of(:january) should output '* * 15 1 *'" do
      interval.on(15).of(:january).to_s.should == '* * 15 1 *'
    end

    it "on(15, 16, 17).of(:january) should output '* * 15,16,17 1 *'" do
      interval.on(15, 16, 17).of(:january).to_s.should == '* * 15,16,17 1 *'
    end
    
    it "on(15..17).of(:january) should output '* * 15-17 1 *'" do
      interval.on(15..17).of(:january).to_s.should == '* * 15-17 1 *'
    end

    it "on(15, 16, 17).of(:january) should output '* * 15 1,6,12 *'" do
      interval.on(15).of(:jan, :jun, :dec).to_s.should == '* * 15 1,6,12 *'
    end
    
    it "at('2.13pm').on_the_('15th').of(:january) should output '13 14 15 1'" do
      interval.at('2.13pm').on_the(15).of(:january).to_s.should == '13 14 15 1 *'
    end
    
    it "every(15).minutes.on_the('15th').of(:january) should output '0,15,30,45 * 15 1 *'" do
      interval.every(15).minutes.on_the('15th').of(:january).to_s.should == '0,15,30,45 * 15 1 *'
    end
  end

  def interval
    @interval ||= Cronos::Interval.new
  end
end
