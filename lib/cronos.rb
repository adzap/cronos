module Cronos

  class Interval
    attr_accessor :min, :hour, :day, :month, :dow

    MONTHS = [:jan, :feb, :mar, :apr, :may, :jun, :jul, :aug, :sep, :oct, :nov, :dec]

    DAYS = [:sun, :mon, :tue, :wed, :thu, :fri, :sat]

    def initialize
      # @min, @hour, @day, @month, @dow = ['*'] * 5
    end

    def at(time)
      @hour, @min  = *time.to_s.split('.')
      @min = @min.ljust(2, '0') if @min
      raise "invalid time for 'at'" if @min && @min.to_i > 59
      @min ||= 0
      self
    end

    def every(multiple)
      Cronos::RepeatInterval.new(multiple, self)
    end

    def on(*days)
      range = days.first.is_a?(Range)
      days = days.first if range 
      set = days.collect {|day| day.to_s.to_i }
      @day = range ? "#{set.first}-#{set.last}" : set.join(',')
      self
    end
    alias on_the on

    def days(*days)
      set = days.collect {|day| DAYS.index(day.to_s.downcase[0..2].to_sym) }
      @dow = set.join(',')
      self
    end
    alias on_days days

    def of(*months)
      months.collect! {|month| MONTHS.index(month.to_s.downcase[0..2].to_sym) + 1 unless month.is_a?(Fixnum) }
      @month = months.join(',') 
      self
    end

    def am
      self
    end
    
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
