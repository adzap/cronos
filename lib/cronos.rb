module Cronos

  class Interval
    attr_accessor :min, :hour, :day, :month, :dow

    MONTHS = [:jan, :feb, :mar, :apr, :may, :jun, :jul, :aug, :sep, :oct, :nov, :dec]

    DAYS = [:sun, :mon, :tue, :wed, :thu, :fri, :sat]

    # Time:
    #   at(12)
    #   at(1.30)
    #   at('01.30')
    #   at(14.30)
    #   at(2).pm
    def at(time)
      @hour, @min  = *time.to_s.split('.')
      @hour = @hour.to_i
      raise "invalid hour value for 'at'" if @hour > 23 

      if @min
        @min = @min.ljust(2, '0').to_i
        raise "invalid minute value for 'at'" if @min > 59
      end
      @min ||= 0
      self
    end

    # Repeats an interval:
    #   every(10).minutes
    #   every(6).hours
    #   every(2).months
    #
    def every(multiple)
      Cronos::RepeatInterval.new(multiple, self)
    end

    # Days of month:
    #   on(13)
    #   on('13th')
    #   on(13..17)
    #   on_the('13th')
    #
    def on(*args)
      if args.first.is_a?(Range)
        range = args.first
        @day = "#{range.first.to_i}-#{range.last.to_i}"
      else
        list = args.collect {|day| day.to_s.to_i }
        @day = list.join(',')
      end 
      self
    end
    alias on_the on

    # Days of the week:
    #   days(:monday)
    #   days('Monday')
    #   days(:mon)
    #   on_day(:monday)
    #   days(:mon, :tues)
    #   on_days(:mon, :tues)
    #
    def days(*args)
      list = args.collect {|day| DAYS.index(day.to_s.downcase[0..2].to_sym) }
      @dow = list.join(',')
      self
    end
    alias on_days days
    alias on_day days

    # Months:
    #   of(:january)
    #   of('January')
    #   of(:jan
    #   of(:jan, :feb, :mar)
    #   of_months(1, 2, 3)
    #
    def of(*args)
      list = args.collect {|month| MONTHS.index(month.to_s.downcase[0..2].to_sym) + 1 unless month.is_a?(Fixnum) }
      @month = list.join(',') 
      self
    end
    alias of_months of

    def am
      self
    end
    
    # Modifies hour to be in 2nd half of day
    def pm
      @hour = hour.to_i + 12 if hour.to_i < 12
      self
    end

    def hourly
      @min  = 0
      @hour = nil
      self
    end

    def daily
      @min   ||= 0
      @hour  ||= 0
      @day   = nil
      @month = nil
      @dow   = nil
      self
    end
    alias once_a_day daily

    def weekly
      @min   ||= 0
      @hour  ||= 0
      @dow   ||= 0
      @day   = nil
      @month = nil
      self
    end
    alias once_a_week weekly
    
    def monthly
      @min   ||= 0
      @hour  ||= 0
      @day   = 1
      @month = nil
      @dow   = nil
      self
    end
    alias once_a_month monthly

    def weekdays
      @min  ||= 0
      @hour ||= 0
      @dow  = '1-5'
      self
    end
    
    def weekends
      @min  ||= 0
      @hour ||= 0
      @dow  = '0,6'
      self
    end

    def to_s
      "#{min || '*'} #{hour || '*'} #{day || '*'} #{month || '*'} #{dow || '*'}"
    end

  end

  class RepeatInterval

    def initialize(multiple, interval)
      @multiple, @interval = multiple, interval
    end

    def minutes
      raise 'Multiple of minutes will not fit into an hour' if (60 % @multiple) > 0
      calculate_intervals(60)
      @interval.min = self 
      @interval
    end
    
    def hours
      raise 'Multiple of hours will not fit into a day' if (24 % @multiple) > 0
      calculate_intervals(24)
      @interval.min  = 0
      @interval.hour = self 
      @interval
    end

    def months
      raise 'Multiple of months will not fit into a year' if (12 % @multiple) > 0
      calculate_intervals(12, 1)
      @interval.min  ||= 0
      @interval.hour ||= 0
      @interval.day  ||= 1
      @interval.month = self 
      @interval
    end

    def calculate_intervals(base, initial = 0)
      repeats = (base / @multiple) - 1
      set = [initial]
      1.upto(repeats) {|factor| set << (factor * @multiple + initial) }
      @intervals = set
    end

    def to_s
      @intervals.join(',')
    end

    def to_a
      @intervals
    end
  end 
end
