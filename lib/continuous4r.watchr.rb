# Run me with:
#
#   $ watchr continuous4r.watchr.rb

# --------------------------------------------------
# Convenience Methods
# --------------------------------------------------
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

# --------------------------------------------------
# Watchr Rules
# --------------------------------------------------
watch( '^test.*/test_.*\.rb'   )   { |m| run( "ruby -rubygems %s"              % m[0] ) }
watch( '^lib/(.*)\.rb'         )   { |m| run( "ruby -rubygems test/test_%s.rb" % m[1] ) }
watch( '^lib/.*/(.*)\.rb'      )   { |m| run( "ruby -rubygems test/test_%s.rb" % m[1] ) }
watch( '^test/test_helper\.rb' )   { run_all_tests }
# flog source files
require 'lib/continuous4r.rb'

watch( '^lib/(.*)\.rb' ) do |source|
  require 'lib/rdoc_builder.rb'
  rdoc_builder = RdocBuilder.new
  rdoc_builder.build('project_name', false, nil)
  require 'lib/dcov_builder.rb'
  dcov_builder = DcovBuilder.new
  dcov_builder.build('project_name', false, nil)
  percentage = dcov_builder.quality_percentage
  run("notify-send 'Ruby documentation warning' 'Only #{percentage}% of your code is documented'")
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

