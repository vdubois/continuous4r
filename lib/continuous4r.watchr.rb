# Run me with:
#
#   $ watchr continuous4r.watchr.rb

# --------------------------------------------------
# Convenience Methods
# --------------------------------------------------
WORK_DIR = "tmp/continuous4r"
FLOG_ICON = "seattle_rb.png"
REEK_ICON = "reek.jpeg"

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

# instanciating notifier class
def generate_notifier_class(configuration)
  notifier_type = configuration.options[:notify][:system]
  require "#{notifier_type}_notifier.rb"
  notifier_class = Object.const_get("#{notifier_type.capitalize}Notifier")
end

# flogging a ruby file
def run_flog(file, configuration)
  notifier_class = generate_notifier_class(configuration)
  analyzer = FlogAnalyzer.new(file)
  analyzer.perform
  if analyzer.average_score > configuration.options[:flog][:required]
    notifier_class.new("FLOG WARNING", "The average score for #{file} is #{analyzer.average_score}", FLOG_ICON).notify
    if configuration.options[:flog][:detailed]
      notifier_class.new("FLOG WARNING", "The total score for #{file} is #{analyzer.total_score}", FLOG_ICON).notify
      analyzer.flogged_methods.each do |fm|
        notifier_class.new("FLOG WARNING", "Score for #{fm[0]} : #{fm[1]}", FLOG_ICON).notify
      end
    end
  end
end

# flogging a ruby file
def run_reek(file, configuration)
  notifier_class = generate_notifier_class(configuration)
  analyzer = ReekAnalyzer.new(file)
  analyzer.perform
  if analyzer.code_smells.length > 0
    notifier_class.new("REEK WARNING", "There are code smells in #{file}", REEK_ICON).notify
    #if configuration.options[:flog][:detailed]
    (0..2).to_a.each do |index|
      notifier_class.new("REEK WARNING", "#{analyzer.code_smells[index]}", REEK_ICON).notify
    end
    analyzer.to_html
    Utils.run_command("firefox #{Utils::WORK_DIR}/reek.html")
  end
end

# run continuous dcov task
def run_dcov(file, configuration)
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

def watch_and_send(configuration, watch_regexp, analyzer)
  if !watch_regexp.nil?
    watch(watch_regexp) do |source|
      self.send("run_#{analyzer}", source[0], configuration)
    end
  end
end

configuration.options.each_key do |key|
  require "#{key}_analyzer.rb" unless [:all, :notify].include?(key)
  if configuration.options[key][:files].is_a?(Array)
    configuration.options[key][:files].each do |files_regexp|
      watch_and_send(configuration, files_regexp, key)
    end
  else
    watch_and_send(configuration, configuration.options[key][:files], key)
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

