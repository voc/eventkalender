# frozen_string_literal: true

require 'spec_helper'

describe 'Integer' do
  # @deprecation: Ruby 2.3.3 support will be dropped soon.
  CLASS_TYPE = if RUBY_VERSION < '2.4.0'
                 Fixnum
               else
                 Integer
               end

  describe 'Constants' do
    it 'should have seconds per day,
                    seconds per hour and
                    seconds per minutes defined' do
      expect(Integer::SECONDS_IN_DAY).to eq 86_400
      expect(Integer::SECONDS_IN_HOUR).to eq 3_600
      expect(Integer::SECONDS_IN_MINUTES).to eq 60
    end
  end

  describe '.ago' do
    it 'should return a pased time stamp' do
      expect(2.days.ago.to_s).to eq (Time.now - 172_800).to_s
    end

    it 'should return Time object' do
      expect(23.days.ago).to be_instance_of Time
    end
  end

  describe '.minutes' do
    it 'should return minutes in seconds' do
      expect(2.minutes).to eq 120
    end

    it 'should return Integer object' do
      expect(23.days).to be_instance_of CLASS_TYPE
    end
  end

  describe '.hours' do
    it 'should return hours in seconds' do
      expect(2.hours).to eq 7_200
    end

    it 'should return Integer object' do
      expect(23.days).to be_instance_of CLASS_TYPE
    end
  end

  describe '.days' do
    it 'should return days in seconds' do
      expect(2.days).to eq 172_800
    end

    it 'should return Integer object' do
      expect(23.days).to be_instance_of CLASS_TYPE
    end
  end
end
