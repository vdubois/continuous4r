# Projet par defaut du systeme
# Author:: Vincent Dubois
# Date : 08 aout 2009 - version 0.0.5
require 'continuous4r_configuration.rb'
class Continuous4rProject
  attr_accessor :tasks, :name, :description
  attr_accessor :auto_install_gems, :auto_install_tools, :ignore_test_failures
  attr_accessor :url, :logo, :company, :members, :bugtracker, :gems
  # Constructeur par défaut
  def initialize
    @name = "Default project name"
    @description = "Default project description"
    @auto_install_gems = true
    @auto_install_tools = true
    @ignore_test_failures = true
    @url = "http://defaultprojecturl"
    @logo = "http://defaultprojecturl/logo.png"
    @company = nil
    @members = []
    @bugtracker = nil
    @gems = []
  end

  def self.configure
    configuration = Continuous4rConfiguration.new
    yield configuration
  end

end

