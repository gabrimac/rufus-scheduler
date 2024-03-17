
#
# Specifying rufus-scheduler
#
# Wed Apr 17 06:00:59 JST 2013
#

require 'spec_helper'


describe Rufus::Scheduler::AtJob do

  before :each do
    @scheduler = Rufus::Scheduler.new
  end
  after :each do
    @scheduler.shutdown
  end

  describe '#unschedule' do

    it 'unschedules the job' do

      job = @scheduler.at(Time.now + 3600, :job => true) do
      end

      job.unschedule

      sleep 0.4

      expect(@scheduler.jobs.size).to eq(0)
    end
  end

  describe '#scheduled_at' do

    it 'returns the Time at which the job got scheduled' do

      job = @scheduler.schedule_at((t = Time.now) + 3600) {}

      expect(job.scheduled_at.to_i).to be >= t.to_i - 1
      expect(job.scheduled_at.to_i).to be <= t.to_i + 1
    end
  end

  describe '#time' do

    it 'returns the time at which the job will trigger' do

      t = Time.now + 3600

      job = @scheduler.schedule_at t do; end

      expect(job.time.to_f).to eq(t.to_f)
    end
  end

  describe '#previous_time' do

    it 'returns the previous #time' do

      t = Time.now + 1
      t0 = nil
      t1 = nil

      job =
        @scheduler.schedule_at t do |j|
          t1 = Time.now
          t0 = j.previous_time
        end

      sleep 1.4

      expect(t0.to_f).to eq(t.to_f)
      expect(t1).to be > t
    end
  end

  describe '#next_times' do

    it 'returns the next n times' do

      job = @scheduler.schedule_at Time.now + 1 do; end

      expect(job.next_times(3)).to eq([ job.next_time ])
    end

    it 'returns an empty array if it already triggered' do

      job = @scheduler.schedule_at Time.now + 0.001 do; end

      sleep 0.350

      expect(job.next_times(3)).to eq([])
    end
  end

  describe '#next_times_until' do

    it 'returns the next times until the given time' do

      job = @scheduler.schedule_at Time.now + 1 do; end

      expect(job.next_times_until(Time.now + 3)).to eq([ job.next_time ])
    end

    it 'returns an empty array if it already triggered' do
      
      job = @scheduler.schedule_at Time.now + 0.001 do; end

      sleep 0.350

      expect(job.next_times_until(Time.now + 3)).to eq([])
    end
  end
end

