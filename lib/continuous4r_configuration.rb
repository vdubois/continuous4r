# Configuration du systeme
# Author:: Vincent Dubois
# Date : 30 septembre 2009 - version 0.0.5
class Continuous4rConfiguration

  def all(options = {})
    puts "notify this"
  end

  def notify(options = {})
    puts "notify this"
  end

  def flog(options = {})
    puts "notify this"
  end

  def flay(options = {})
    puts "notify this"
  end

  def dcov(options = {})
    puts "notify this"
  end

  def rcov(options = {})
    puts "notify this"
  end

  def saikuro(options = {})
    puts "notify this"
  end

  def reek(options = {})
    puts "notify this"
  end

  def roodi(options = {})
    puts "notify this"
  end

  def tests(options = {})
    puts "notify this"
  end

  def zentest(options = {})
    puts "notify this"
  end

  def method_missing(method_name, *args, &block)
    possible_method_names = ['all', 'notify', 'flog', 'flay', 'dcov', 'rcov', 'reek', 'roodi', 'saikuro', 'tests', 'zentests']
    raise "You must specify a method name within [#{possible_method_names.join(', ')}] in order to configure your project" unless possible_method_names.include?(method_name)
  end
end

