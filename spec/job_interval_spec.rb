
#
# Specifying rufus-scheduler
#
# Wed Apr 17 06:00:59 JST 2013
#

require 'spec_helper'


describe Rufus::Scheduler::IntervalJob do

  before :each do
    @scheduler = Rufus::Scheduler.new
  end
  after :each do
    @scheduler.shutdown
  end

  describe '#interval' do

    it 'returns the scheduled interval' do

      job = @scheduler.schedule_interval('1h') do; end

      expect(job.interval).to eq(3600)
    end
  end

  context 'first_at/in' do

    it 'triggers for the first time at first_at' do

      t = Time.now

      job = @scheduler.schedule_interval '3s', :first_in => '1s' do; end

      sleep 2

      #p [ t, t.to_f ]
      #p [ job.last_time, job.last_time.to_f ]
      #p [ job.first_at, job.first_at.to_f ]

      expect(job.first_at).to be_within_1s_of(t + 2)
      expect(job.last_time).to be_within_1s_of(job.first_at)
    end

    describe '#first_at=' do

      it 'alters @next_time' do

        job = @scheduler.schedule_interval '3s', :first_in => '10s' do; end

        fa0 = job.first_at
        nt0 = job.next_time

        job.first_at = Time.now + 3

        fa1 = job.first_at
        nt1 = job.next_time

        expect(nt0).to eq(fa0)
        expect(nt1).to eq(fa1)
      end
    end
  end

  describe '#next_times' do

    it 'returns the next n times' do

      job = @scheduler.schedule_interval '5m' do; end

      times =
        2.times.inject([ job.next_time ]) { |a|
          a << job.next_time_from(a.last)
          a }

      expect(job.next_times(3)).to eq(times)
    end

    it 'takes first_at/in into account' do

      job = @scheduler.schedule_interval '5m', first_in: '3s' do; end

      times =
        2.times.inject([ job.next_time ]) { |a|
          a << job.next_time_from(a.last)
          a }

      expect(job.next_times(3)).to eq(times)

      expect(times.first).to be_between(Time.now + 2.5, Time.now + 3.5)
    end
  end

  describe '#next_times_until' do

    it 'returns the next times until the given time' do

      job = @scheduler.schedule_interval '5m' do; end

      times =
        3.times.inject([ job.next_time ]) { |a|
          a << job.next_time_from(a.last)
          a }

      expect(job.next_times_until(times.last)).to eq(times)
    end

    it 'takes first_at/in into account' do

      job = @scheduler.schedule_interval '5m', first_in: '3s' do; end

      times =
        2.times.inject([ job.next_time ]) { |a|
          a << job.next_time_from(a.last)
          a }

      expect(job.next_times_until(times.last)).to eq(times)

      expect(times.first).to be_between(Time.now + 2.5, Time.now + 3.5)
    end
  end
end

