# Run me with:
#
#   $ watchr continuous4r.watchr.rb

# --------------------------------------------------
# Convenience Methods
# --------------------------------------------------
WORK_DIR = "tmp/continuous4r"

def all_test_files
  Dir['test/**/test_*.rb'] - ['test/test_helper.rb']
end

def run(cmd)
  puts(cmd)
  system(cmd)
end

def run_all_tests
  cmd = "ruby -rubygems -Ilib -e'%w( #{all_test_files.join(' ')} ).each {|file| require file }'"
  run(cmd)
end

# run continuous rdoc task (needed by dcov)
def run_rdoc(project_name)
  require 'rdoc_builder.rb'
  rdoc_builder = RdocBuilder.new
  rdoc_builder.build(project_name, false, nil)
end

class DcovFileAnalyzer
  attr_accessor :file

  def initialize(file)
    @file = file
  end

  def perform
    log = Utils.run_command("dcov #{@file}")
    puts "LOG : #{log}"
  end
end

# run continuous dcov task
def run_dcov(project_name, file)
  #require 'dcov_builder.rb'
  #dcov_builder = DcovBuilder.new
  #dcov_builder.build('project_name', false, nil)
  #percentage = dcov_builder.quality_percentage
  #Utils.run_command("notify-send -t 25000 --icon=#{FileUtils.pwd}/#{WORK_DIR}/notification/dcov.png 'Ruby documentation warning' 'Only #{percentage}% of your code is documented'")
  analyzer = DcovFileAnalyzer.new(file)
  analyzer.perform
end

# --------------------------------------------------
# Watchr Rules
# --------------------------------------------------
watch( '^test.*/test_.*\.rb'   )   { |m| run( "ruby -rubygems %s"              % m[0] ) }
watch( '^lib/(.*)\.rb'         )   { |m| run( "ruby -rubygems test/test_%s.rb" % m[1] ) }
watch( '^lib/.*/(.*)\.rb'      )   { |m| run( "ruby -rubygems test/test_%s.rb" % m[1] ) }
watch( '^test/test_helper\.rb' )   { run_all_tests }
# flog source files
require 'continuous4r.rb'

watch( '^app/(.*)\.rb' ) do |source|
  #run_rdoc('project_name')
  run_dcov('project_name', source[0])
end

# --------------------------------------------------
# Signal Handling
# --------------------------------------------------
# Ctrl-\
Signal.trap('QUIT') do
  puts " --- Running all tests ---\n\n"
  run_all_tests
end

# Ctrl-C
Signal.trap('INT') { abort("\n") }

