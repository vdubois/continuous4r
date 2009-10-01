# Configuration du systeme
# Author:: Vincent Dubois
# Date : 30 septembre 2009 - version 0.0.5
class Continuous4rConfiguration

  # constructor
  def initialize
    @options = {}
  end

  # getting options
  def options
    @options
  end

  # defining all default options
  def all(options = {:activated => true, :detailed => true, :files => ['^app/(.*)\.rb', '^lib/(.*)\.rb']})
    @options.each do |option|
      option ||= {}
      option << options
    end
  end

  # defining notifications
  def notify(options = {:activated => true, :system => 'libnotify'})
    @options[:notify] = options
  end

  # defining flogging options
  def flog(options = {:activated => true})
    @options[:flog] = options
  end

  # defining flay options
  def flay(options = {:activated => true, :mass => 40})
    @options[:flay] = options
  end

  # defining dcov options
  def dcov(options = {:activated => true, :required => 90})
    @options[:dcov] = options
  end

  # defining rcov options
  def rcov(options = {:activated => true, :required => 90})
    @options[:rcov] = options
  end

  # defining saikuro options
  def saikuro(options = {:activated => true, :warning => 5, :error => 7})
    @options[:saikuro] = options
  end

  # defining reek options
  def reek(options = {:activated => true})
    @options[:reek] = options
  end

  # defining roodi options
  def roodi(options = {:activated => true})
    @options[:roodi] = options
  end

  # defining unit tests options
  def tests(options = {:activated => true, :rspec => false})
    @options[:tests] = options
  end

  # defining ZenTest options
  def zentest(options = {:activated => true})
    @options[:zentest] = options
  end

  # catching all unknown method calls
  def method_missing(method_name, *args, &block)
    possible_method_names = ['all', 'notify', 'flog', 'flay', 'dcov', 'rcov', 'reek', 'roodi', 'saikuro', 'tests', 'zentests']
    raise "You must specify a method name within [#{possible_method_names.join(', ')}] in order to configure your project, you specified #{method_name} #{("with #{args.join(", ")} arguments" if args.length > 0)}" unless possible_method_names.include?(method_name)
  end
end

