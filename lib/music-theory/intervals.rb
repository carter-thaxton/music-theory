module MusicTheory

  # Common code used for scales and chords
  # Uses these methods when mixed-in:
  #   intervals
  #   interval(n)
  #   with_intervals(intervals)
  module Intervals

    def alter(n)
      existing_interval = interval(n)

      if existing_interval
        new_interval = yield existing_interval
      else
        new_interval = yield Interval.parse(n, true)
      end

      new_intervals = intervals.clone
      new_intervals.delete(existing_interval) if existing_interval
      new_intervals << new_interval

      with_intervals(new_intervals)
    end

    def no(n)
      new_intervals = intervals.clone

      if n.is_a? Interval
        new_intervals.delete_if {|i| i == n}
      else
        existing_interval = interval(n)
        new_intervals.delete(existing_interval) if existing_interval
      end

      with_intervals(new_intervals)
    end

    def add(interval)
      interval = Interval.parse(interval, true) unless interval.is_a? Interval

      new_intervals = intervals.clone
      new_intervals << interval

      with_intervals(new_intervals)
    end

    def flat(i, n=1)
      # special case for b9.  Don't replace #9
      if i == 9
        ninth = interval(9)
        if ninth && ninth.augmented?
          return add Interval.major(9).flat(n)
        end
      end

      alter(i) {|interval| interval.flat(n) }
    end

    def sharp(i, n=1)
      # special case for #9.  Don't replace b9
      if i == 9
        ninth = interval(9)
        if ninth && (ninth.minor? or ninth.diminished?)
          return add Interval.major(9).sharp(n)
        end
      end

      alter(i) {|interval| interval.sharp(n) }
    end

  end
end
