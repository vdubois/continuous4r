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

def run_flog(file)
  analyzer = FlogAnalyzer.new(file)
  analyzer.perform
end

# run continuous dcov task
def run_dcov(file)
  #require 'dcov_builder.rb'
  #dcov_builder = DcovBuilder.new
  #dcov_builder.build('project_name', false, nil)
  #percentage = dcov_builder.quality_percentage
  #Utils.run_command("notify-send -t 25000 --icon=#{FileUtils.pwd}/#{WORK_DIR}/notification/dcov.png 'Ruby documentation warning' 'Only #{percentage}% of your code is documented'")
  analyzer = DcovAnalyzer.new(file)
  analyzer.perform
end

# --------------------------------------------------
# Watchr Rules
# --------------------------------------------------

require 'yaml'
require 'continuous4r_configuration.rb'
# deserializing configuration
configuration = YAML.load_file("#{FileUtils.pwd}/configuration.yml")

#watch( '^test.*/test_.*\.rb'   )   { |m| run( "ruby -rubygems %s"              % m[0] ) }
#watch( '^lib/(.*)\.rb'         )   { |m| run( "ruby -rubygems test/test_%s.rb" % m[1] ) }
#watch( '^lib/.*/(.*)\.rb'      )   { |m| run( "ruby -rubygems test/test_%s.rb" % m[1] ) }
#watch( '^test/test_helper\.rb' )   { run_all_tests }

def watch_and_send(watch_regexp, analyzer)
  if !watch_regexp.nil?
    watch(watch_regexp) do |source|
      self.send("run_#{analyzer}", source[0])
    end
  end
end

configuration.options.each_key do |key|
  require "#{key}_analyzer.rb" unless [:all, :notify].include?(key)
  if configuration.options[key][:files].is_a?(Array)
    configuration.options[key][:files].each do |files_regexp|
      watch_and_send(files_regexp, key)
    end
  else
    watch_and_send(configuration.options[key][:files], key)
  end
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

