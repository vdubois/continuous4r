$:.unshift(File.dirname(__FILE__)) unless
$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require File.join(File.dirname(__FILE__), 'tasks', 'continuous4r')

require 'rubygems'
require 'date'
require 'erb'
require 'stats_formatter.rb'
require 'tests_formatter.rb'
require 'rspec_formatter.rb'
require 'zen_test_formatter.rb'
require 'subversion_extractor.rb'
require 'git_extractor.rb'
require 'utils.rb'
require 'continuous4r_project.rb'
require 'company.rb'
require 'bugtracker.rb'
#require 'gem.rb'
require 'member.rb'
# ==============================================================================
# Classe modelisant un fichier de description de projet Ruby on Rails
# Author:: Vincent Dubois
# Date : 03 decembre 2007 - version 0.0.1
#        03 fevrier 2009  - version 0.0.2
#        25 fevrier 2009  - version 0.0.3
#        03 mars 2009     - version 0.0.4
#        08 aout 2009     - version 0.0.5
# ==============================================================================
module Continuous4r
  include Utils
  VERSION = '0.0.5'
  URL = "http://github.com/vdubois/continuous4r/tree/master"

  # Support de CruiseControl.rb
  WORK_DIR = "#{ENV['CC_BUILD_ARTIFACTS'].nil? ? "tmp/continuous4r" : "#{ENV['CC_BUILD_ARTIFACTS']}/continuous4r"}"

  TASKS = ['rdoc','dcov','rcov','stats','changelog','flog','xdoclet','flay','reek','roodi','saikuro','tests','zentest']
  #TASKS = ['roodi']

  METRICS_HASH = Hash.new

  # Projet lie
  def self.project
    @@project ||= Continuous4rProject.new
  end

  # Projet lie
  def self.project=(project_param)
    @@project = project_param unless project_param.nil?
  end

  # Methode qui permet de recuperer le nom du build pour la construction du template notamment
  def self.build_name
    @build_name ||= "no build name found"
  end

  # Methode de generation du site au complet
  def self.generate_site
    @build_name = Utils.build_name
    @@project ||= Continuous4rProject.new
    @@project.tasks ||= TASKS
    # Gestion des dependances entre certaines taches
    dependant_tasks = false
    if @@project.tasks.include?('dcov') and !@@project.tasks.include?('rdoc')
      @@project.tasks << 'rdoc'
      dependant_tasks = true
    end
    if @@project.tasks.include?('flay') and !@@project.tasks.include?('stats')
      @@project.tasks << 'stats'
      dependant_tasks = true
    end
    @@project.tasks.reverse! if dependant_tasks
    if (@@project.tasks.include?('flog') or @@project.tasks.include?('dcov') or
        @@project.tasks.include?('flay') or @@project.tasks.include?('reek') or
        @@project.tasks.include?('roodi')) and !@@project.tasks.include?('xdoclet')
      @@project.tasks << 'xdoclet'
    end
    generation_date = DateTime.now
    start_time = Time.now
    auto_install = @@project.auto_install_tools
    auto_install ||= "false"

    puts "====================================================================="
    puts " Continuous Integration for Ruby, starting website generation..."
    puts "---------------------------------------------------------------------"
    puts " Project name    : #{@@project.name}"
    puts " Project URL     : #{@@project.url}"
    puts " Generation date : #{generation_date}"
    puts "---------------------------------------------------------------------"

    # Recuperation des parametres de proxy s'ils existent
    proxy_option = ""
    if File.exist?("#{(Config::CONFIG['host_os'] =~ /mswin/ ? ENV['USERPROFILE'] : ENV['HOME'])}/.continuous4r/proxy.yml")
      require 'YAML'
      proxy_options = YAML.load_file("#{(Config::CONFIG['host_os'] =~ /mswin/ ? ENV['USERPROFILE'] : ENV['HOME'])}/.continuous4r/proxy.yml")
      proxy_option = " -p \"http://#{proxy_options['proxy']['login']}:#{proxy_options['proxy']['password']}@#{proxy_options['proxy']['server']}:#{proxy_options['proxy']['port']}\""
    end

    # Verification de presence et de la version de Rubygems
    puts " Checking presence and version of RubyGems..."
    rubygems_version = Utils.run_command("gem --version")
    if rubygems_version.empty?
      raise " You don't seem to have RubyGems installed, please go first to http://rubygems.rubyforge.org"
    end

    # Verification de la presence d'hpricot
    Utils.verify_gem_presence("hpricot", auto_install, proxy_option)
    # Verification de la presence de dcov
    Utils.verify_gem_presence("dcov", auto_install, proxy_option)

    # Chargement/Verification des gems necessaires a l'application
    puts " Checking gems for this project, please hold on..."
    begin
      @@project.gems.each do |gem|
        puts " Checking for #{gem.name} gem, version #{gem.version}..."
        gem_version = Utils.run_command("gem list #{gem.name}")
        if gem_version.empty? or gem_version.index("#{gem.version}").nil?
          if @@project.auto_install_gems == "false"
            raise " The #{gem.name} gem with version #{gem.version} is needed. Please run '#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install #{gem.name} --version #{gem.version}' to install it.\n BUILD FAILED."
          end
          gem_installed = Utils.run_command("#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install #{gem.name} --version #{gem.version}#{proxy_option} 2>&1")
          if !gem_installed.index("ERROR").nil?
            raise " Unable to install #{gem.name} gem with version #{gem.version}.\n BUILD FAILED."
          end
        end
      end
    rescue
      puts " No gems declared for this project, continuing..."
    end

    puts "---------------------------------------------------------------------"
    # Creation du repertoire de travail
    if File.exist?(WORK_DIR)
      FileUtils.rm_rf(WORK_DIR)
    end
    FileUtils.mkdir_p WORK_DIR

    # On copie le fichier de configuration de Roodi
    FileUtils.cp("#{File.dirname(__FILE__)}/site/roodi.yml", "#{WORK_DIR}/roodi.yml")

    # On copie le fichier de configuration de Reek
    FileUtils.cp("#{File.dirname(__FILE__)}/site/defaults.reek", "#{RAILS_ROOT}/defaults.reek")

    # Construction des taches
    @@project.tasks.each do |task|
      self.build_task task, @@project.name, auto_install, proxy_option
      puts "\n---------------------------------------------------------------------"
    end
    puts " All tasks done."
    puts "\n---------------------------------------------------------------------"

    # On copie les feuilles de styles
    FileUtils.cp_r("#{File.dirname(__FILE__)}/site/style/", "#{WORK_DIR}/")

    # On copie la partie flash
    FileUtils.cp_r("#{File.dirname(__FILE__)}/site/charts/", "#{WORK_DIR}/")
    # Production du fichier XML des indicateurs de qualite
    page_file = File.open("#{Continuous4r::WORK_DIR}/build.xml", "w")
    erb = ERB.new(File.read("#{File.dirname(__FILE__)}/site/build.xml.erb"))
    page_file.write(erb.result)
    page_file.close

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
    unless @@project.bugtracker.nil?
      puts " Building issue tracking page..."
      Utils.erb_run "issue-tracking", false
    end
    puts " Building project reports page..."
    Utils.erb_run "continuous4r-reports", false
    @@project.tasks.each do |task|
      task_class = Object.const_get("#{task.capitalize}Builder")
      task_builder = task_class.new
      next if task_builder.respond_to?(:prerequisite_met?) and !task_builder.prerequisite_met?
      puts " Building #{task} page..."
      Utils.erb_run task, true
    end

    # On supprime le fichier de configuration de Reek car il est à la racine du projet Rails
    FileUtils.rm "#{RAILS_ROOT}/defaults.reek", :force => true

    end_time = Time.now
    total_time = end_time - start_time
    hours = (total_time / 3600).to_i
    total_time -= (3600 * hours)
    minutes = (total_time / 60).to_i
    total_time -= (60 * minutes)
    seconds = total_time.to_i
    puts "\n [BUILD SUCCESSFUL] Built in #{"#{hours} hour#{"s" if hours > 1} " if hours > 0}#{"#{minutes} minute#{"s" if minutes > 1} " if minutes > 0}#{"#{seconds} second#{"s" if seconds > 1} " if seconds > 0}"
    puts "====================================================================="
  end

  # Methode qui permet de construire une tache de nom donne
  def self.build_task task, project_name, auto_install, proxy_option
    require "#{task}_builder.rb"
    task_class = Object.const_get("#{task.capitalize}Builder")
    task_builder = task_class.new
    if task_builder.respond_to?(:prerequisite_met?)
      if !task_builder.prerequisite_met?
        puts task_builder.prerequisite_unmet_message
        return
      end
    end
    task_builder.build(project_name, auto_install, proxy_option)
    if task_builder.respond_to?(:quality_percentage)
      METRICS_HASH[task_builder.quality_indicator_name] = task_builder.quality_percentage
    end
  end

end

