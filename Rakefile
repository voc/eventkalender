# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'inch/rake'
require 'rubocop/rake_task'


RSpec::Core::RakeTask.new(:spec)
Inch::Rake::Suggest.new
RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names', '--lint']
end

task default: %i[spec rubocop inch]
