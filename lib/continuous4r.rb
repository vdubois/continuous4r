$:.unshift(File.dirname(__FILE__)) unless
$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require File.join(File.dirname(__FILE__), 'tasks', 'continuous4r')

require 'rubygems'
require 'XmlElements'
require 'date'
require 'erb'
require 'stats_formatter.rb'
require 'tests_formatter.rb'
require 'zen_test_formatter.rb'
require 'subversion_extractor.rb'
require 'git_extractor.rb'
require 'utils.rb'

# ==============================================================================
# Classe modelisant un fichier de description de projet Ruby on Rails
# Author:: Vincent Dubois
# Date : 03 decembre 2007 - version 0.0.1
#        03 fevrier 2009  - version 0.0.2
# ==============================================================================
module Continuous4r
  include Utils
  VERSION = '0.0.2'

  # Support de CruiseControl.rb
  WORK_DIR = "#{ENV['CC_BUILD_ARTIFACTS'].nil? ? "tmp/continuous4r" : "#{ENV['CC_BUILD_ARTIFACTS']}/continuous4r"}"
  
  TASKS = ['dcov','rcov','rdoc','stats','changelog','flog','xdoclet','flay','reek','roodi','saikuro','tests','zentest']

  # Methode de generation du site au complet
  def self.generate_site
    tasks = TASKS
    project = XmlElements.fromString(File.read("#{RAILS_ROOT}/continuous4r-project.xml"))
    generation_date = DateTime.now
    auto_install = project['auto-install-tools']
    auto_install ||= "false"

    puts "====================================================================="
    puts " Continuous Integration for Ruby, starting website generation..."
    puts "---------------------------------------------------------------------"
    puts " Project name    : #{project['name']}"
    puts " Project URL     : #{project.url.text}"
    puts " Generation date : #{generation_date}"
    puts "---------------------------------------------------------------------"

    # Récupération des paramètres de proxy s'ils existent
    proxy_option = ""
    if File.exist?("#{(Config::CONFIG['host_os'] =~ /mswin/ ? ENV['USERPROFILE'] : ENV['HOME'])}/.continuous4r/proxy.yml")
      require 'YAML'
      proxy_options = YAML.load_file("#{(Config::CONFIG['host_os'] =~ /mswin/ ? ENV['USERPROFILE'] : ENV['HOME'])}/.continuous4r/proxy.yml")
      proxy_option = " -p \"http://#{proxy_options['proxy']['login']}:#{proxy_options['proxy']['password']}@#{proxy_options['proxy']['server']}:#{proxy_options['proxy']['port']}\""
    end

    # Vérification de présence et de la version de Rubygems
    puts " Checking presence and version of RubyGems..."
    rubygems_version = Utils.run_command("gem --version")
    if rubygems_version.empty?
      raise " You don't seem to have RubyGems installed, please go first to http://rubygems.rubyforge.org"
    end

    # Verification de la presence d'hpricot
    Utils.verify_gem_presence("hpricot", auto_install, proxy_option)

    # Chargement/Vérification des gems nécessaires à l'application
    puts " Checking gems for this project, please hold on..."
    project.gems.each('gem') do |gem|
      puts " Checking for #{gem['name']} gem, version #{gem['version']}..."
      gem_version = Utils.run_command("gem list #{gem['name']}")
      if gem_version.empty? or gem_version.index("#{gem['version']}").nil?
        if project['auto-install-gems'] == "false"
          raise " The #{gem['name']} gem with version #{gem['version']} is needed. Please run '#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install #{gem['name']} --version #{gem['version']}' to install it.\n BUILD FAILED."
        end        
        gem_installed = Utils.run_command("#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install #{gem['name']} --version #{gem['version']}#{proxy_option} 2>&1")
        if !gem_installed.index("ERROR").nil?
          raise " Unable to install #{gem['name']} gem with version #{gem['version']}.\n BUILD FAILED."
        end
      end
    end

    puts "---------------------------------------------------------------------"
    # Création du répertoire de travail
    if File.exist?(WORK_DIR)
      FileUtils.rm_rf(WORK_DIR)
    end
    Dir.mkdir WORK_DIR

    # Construction des taches
    tasks.each do |task|
      self.build_task task, project['name'], auto_install, proxy_option
      puts "\n---------------------------------------------------------------------"
    end
    puts " All tasks done."
    puts "\n---------------------------------------------------------------------"
    # On copie les feuilles de styles
    FileUtils.cp_r("#{File.dirname(__FILE__)}/site/style/", "#{WORK_DIR}/")
    # On copie les images
    FileUtils.cp_r("#{File.dirname(__FILE__)}/site/images/", "#{WORK_DIR}/")
    FileUtils.copy_file("#{File.dirname(__FILE__)}/site/images/continuous4r-logo.png", "#{WORK_DIR}/continuous4r-logo.png")
    puts " Building project information page..."
    Utils.erb_run "index", false
    puts " Building team list page..."
    Utils.erb_run "team-list", false
    puts " Building project dependencies page..."
    Utils.erb_run "dependencies", false
    puts " Building source control management page..."
    Utils.erb_run "scm-usage", false
    puts " Building issue tracking page..."
    Utils.erb_run "issue-tracking", false
    puts " Building project reports page..."
    Utils.erb_run "continuous4r-reports", false
    tasks.each do |task|
      puts " Building #{task} page..."
      Utils.erb_run task, true
    end
    puts "\n BUILD SUCCESSFUL."
    puts "====================================================================="
  end

  # Methode qui permet de construire une tache de nom donne
  def self.build_task task, project_name, auto_install, proxy_option
    require "#{task}_builder.rb"
    task_class = Object.const_get("#{task.capitalize}Builder")
    task_builder = task_class.new
    task_builder.build(project_name, auto_install, proxy_option)
  end
end
