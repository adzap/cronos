module Cronos

  VERSION = '0.4.0'

  def self.schedule(task)
    TaskInterval.new(task)
  end

  class Interval
    attr_accessor :min, :hour, :day, :month, :dow

    MONTHS = [nil, :jan, :feb, :mar, :apr, :may, :jun, :jul, :aug, :sep, :oct, :nov, :dec]

    DAYS = [:sun, :mon, :tue, :wed, :thu, :fri, :sat]

    # Time:
    #   at(12)
    #   at(1.30)
    #   at('01.30')
    #   at(14.30)
    #   at('2pm')
    #
    def at(time)
      @hour, @min, meridian = parse_time(time)

      raise "invalid hour value for 'at'" if @hour > 12 && meridian
      raise "invalid minute value for 'at'" if @min > 59
        
      case meridian
        when 'am': @hour = 0 if @hour == 12 
        when 'pm': @hour += 12 if @hour < 12
      end
      raise "invalid hour value for 'at'" if @hour > 23
      self
    end

    # Repeats an interval:
    #   every(10).minutes
    #   every(6).hours
    #   every(2).months
    #
    # or use as an alias for #on or #days
    #   every(:monday)
    #   every(:mon, :tues)
    #   every('Monday'.. 'Wednesday')
    #   every('February', :march)
    #   every('Feb'..'June')
    #
    def every(*multiple)
      return RepeatInterval.new(multiple.first, self) if multiple.first.is_a?(Fixnum)

      if multiple.all? {|abbr| is_month?(abbr) }
        of(*multiple)
      elsif multiple.all? {|abbr| is_day?(abbr) }
        days(*multiple)
      else
        raise "Unknown interval type passed to #every"
      end
    end

    # Days of month:
    #   on(13)
    #   on('13th')
    #   on(13..17)
    #   on('13th'..'17th')
    #   on(13...18)
    #   on_the('13th')
    #
    def on(*args)
      if args.first.is_a?(Range)
        @day = format_range(args.first)
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
    #   days(1..3)
    #   days('mon'..'wed')
    #   days(1...4)
    #   on_day(:monday)
    #   days(:mon, :tues)
    #   on_days(:mon, :tues)
    #
    def days(*args)
      if args.first.is_a?(Range)
        @dow = format_range(args.first)
      else
        list = args.map {|day| day_value(day) unless day.is_a?(Fixnum) }
        @dow = list.join(',')
      end
      self
    end
    alias on_days days
    alias on_day days

    # Months:
    #   of(:january)
    #   of('January')
    #   of(:jan)
    #   of(:jan, :feb, :mar)
    #   of(1..3)
    #   of('jan'..'mar')
    #   of(1...4)
    #   of_months(1, 2, 3)
    #   in(:january)
    #
    def of(*args)
      if args.first.is_a?(Range)
        @month = format_range(args.first)
      else
        list = args.map {|month| month_value(month) unless month.is_a?(Fixnum) }
        @month = list.join(',')
      end
      self
    end
    alias of_months of
    alias in of

    def hourly
      @min  = 0
      @hour = nil
      self
    end

    def daily
      @min   ||= 0
      @hour  ||= 0
      @day   = nil
      self
    end
    alias once_a_day daily

    def midnight
      @min  = 0
      @hour = 0
      self
    end
    alias at_midnight midnight

    def midday
      @min  = 0
      @hour = 12
      self
    end
    alias at_midday midday

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
      @day   ||= 1
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

    def to_hash
      {
        :minute  => "#{min   || '*'}",
        :hour    => "#{hour  || '*'}",
        :day     => "#{day   || '*'}",
        :month   => "#{month || '*'}",
        :weekday => "#{dow   || '*'}"
      }
    end

    private

    def parse_time(time)
      meridian = /pm|am/i.match(time.to_s)[0].downcase rescue nil
      hour, min = *time.to_s.split('.')

      hour = hour.to_i
      min = min.strip.ljust(2, '0').to_i if min
      min ||= 0

      return hour, min, meridian
    end

    def format_range(range)
      values = [range.first, range.last]

      if values.all? {|v| v.to_i > 0 }
        first, last = values.first.to_i, values.last.to_i
      elsif values.all? {|abbr| is_month?(abbr) }
        first, last = month_value(values.first), month_value(values.last)
      elsif values.all? {|abbr| is_day?(abbr) }
        first, last = day_value(values.first), day_value(values.last)
      end

      int_range = range.exclude_end? ? first...last : first..last
      list = Array(int_range).sort
      "#{list.first}-#{list.last}"
    end

    def is_month?(value)
      MONTHS.include?(value.to_s.downcase[0..2].to_sym)
    end

    def month_value(value)
      MONTHS.index(value.to_s.downcase[0..2].to_sym)
    end

    def is_day?(value)
      DAYS.include?(value.to_s.downcase[0..2].to_sym)
    end

    def day_value(value)
      DAYS.index(value.to_s.downcase[0..2].to_sym)
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

  class TaskInterval < Interval
    attr_accessor :task

    def initialize(task)
      @task = task
    end

    def to_s
      "#{super} #{@task}"
    end
  end

end
