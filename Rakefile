# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'inch/rake'

RSpec::Core::RakeTask.new(:spec)
Inch::Rake::Suggest.new

task default: %i[spec inch]
