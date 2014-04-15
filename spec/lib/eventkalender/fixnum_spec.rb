require 'spec_helper'

describe 'Fixnum' do
  describe 'Constants' do
    it 'should have seconds per day,
                    seconds per hour and
                    seconds per minutes defined' do
      Fixnum::SECONDS_IN_DAY.should     == 86400
      Fixnum::SECONDS_IN_HOUR.should    == 3600
      Fixnum::SECONDS_IN_MINUTES.should == 60
    end
  end

  describe '.ago' do
    it 'should return a pased time stamp' do
      2.days.ago.to_s.should == (Time.now - 172800).to_s
    end

    it 'should return Time object' do
      23.days.ago.class.should == Time
    end
  end

  describe '.minutes' do
    it 'should return minutes in seconds' do
      2.minutes.should == 120
    end

    it 'should return Fixnum object' do
      23.days.class.should == Fixnum
    end
  end

  describe '.hours' do
    it 'should return hours in seconds' do
      2.hours.should == 7200
    end

    it 'should return Fixnum object' do
      23.days.class.should == Fixnum
    end
  end

  describe '.days' do
    it 'should return days in seconds' do
      2.days.should == 172800
    end

    it 'should return Fixnum object' do
      23.days.class.should == Fixnum
    end
  end
end