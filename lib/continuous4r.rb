$:.unshift(File.dirname(__FILE__)) unless
$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require File.join(File.dirname(__FILE__), 'tasks', 'continuous4r')

require 'rubygems'
require 'XmlElements'
require 'date'
require 'erb'
require 'capistrano_formatter.rb'
require 'heckle_formatter.rb'
require 'httperf_formatter.rb'
require 'stats_formatter.rb'
require 'tests_formatter.rb'
require 'zen_test_formatter.rb'
require 'subversion_extractor.rb'

# ==============================================================================
# Classe modelisant un fichier de description de projet Ruby/Rails
# Author:: Vincent Dubois
# Date : 03 decembre 2007 - version 0.0.1
#        03 fevrier 2009  - version 0.0.2
# ==============================================================================
module Continuous4r
  VERSION = '0.0.2'

  # Support de CruiseControl.rb
  WORK_DIR = "#{ENV['CC_BUILD_ARTIFACTS'].nil? ? "continuous4r_build" : "#{ENV['CC_BUILD_ARTIFACTS']}/continuous4r_build"}"

  # Methode de generation du site au complet
  def self.generate_site
    project = XmlElements.fromString(File.read("#{RAILS_ROOT}/continuous4r-project.xml"))
    generation_date = DateTime.now
    puts "====================================================================="
    puts " Continuous Integration for Ruby, starting website generation..."
    puts "---------------------------------------------------------------------"
    puts " Project name    : #{project['name']}"
    puts " Project URL     : #{project.url.text}"
    puts " Generation date : #{generation_date}"
    puts "---------------------------------------------------------------------"

    # Récupération des paramètres de proxy s'ils existent
    proxy_option = ""
    if File.exist?("#{ENV['HOME']}/.continuous4r/proxy.yml")
      require 'YAML'
      proxy_options = YAML.load_file("#{ENV['HOME']}/.continuous4r/proxy.yml")
      proxy_option = " -p \"http://#{proxy_options['proxy']['login']}:#{proxy_options['proxy']['password']}@#{proxy_options['proxy']['server']}:#{proxy_options['proxy']['port']}\""
    end

    # Vérification de présence et de la version de Rubygems
    puts " Checking presence and version of RubyGems..."
    rubygems_version = run_command("gem --version")
    if rubygems_version.empty?
      raise " You don't seem to have RubyGems installed, please go first to http://rubygems.rubyforge.org"
    end

    # Verification de la presence d'hpricot
    hpricot_version = run_command("gem list hpricot")
    if hpricot_version.empty?
      puts " Installing Hpricot..."
      hpricot_installed = system("#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install hpricot#{proxy_option}")
      if !hpricot_installed
        raise " Install for Hpricot failed with command '#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install hpricot#{proxy_option}'\n BUILD FAILED."
      end
    end

    # Chargement/Vérification des gems nécessaires à l'application
    puts " Checking gems for this project, please hold on..."
    project.gems.each('gem') do |gem|
      puts " Checking for #{gem['name']} gem, version #{gem['version']}..."
      gem_version = run_command("gem list #{gem['name']}")
      if gem_version.empty? or gem_version.index("#{gem['version']}").nil?
        gem_installed = run_command("#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install #{gem['name']} --version #{gem['version']}#{proxy_option} 2>&1")
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

    auto_install = project['auto-install-tools']
    auto_install ||= "false"

    # Construction des taches
    begin
      ['dcov','rcov','rdoc'].each do |task|
        self.build_task task, project['name'], project.scm, auto_install, proxy_option
        puts "\n---------------------------------------------------------------------"
      end
      puts " All tasks done."
    rescue Exception => e
      if e.to_s == "no childs named 'task' found!"
        puts " No task to build."
      else
        raise e
      end
    end
    puts "\n---------------------------------------------------------------------"
    # On copie les feuilles de styles
    `cp -R #{File.dirname(__FILE__)}/site/style/ #{WORK_DIR}/`
    # On copie les images
    `cp -R #{File.dirname(__FILE__)}/site/images/ #{WORK_DIR}/`
    `cp #{File.dirname(__FILE__)}/site/images/continuous4r-logo.png #{WORK_DIR}/`
    puts " Building project information page..."
    erb_run "index"
    puts " Building team list page..."
    erb_run "team-list"
    puts " Building project dependencies page..."
    erb_run "dependencies"
    puts " Building source control management page..."
    erb_run "scm-usage"
    puts " Building issue tracking page..."
    erb_run "issue-tracking"
    puts " Building project reports page..."
    erb_run "continuous4r-reports"
    begin
      project.tasks.each('task') do |task|
        puts " Building #{task['name']} page..."
        erb_run task['name']
      end
    rescue Exception => e
      unless e.to_s == "no childs named 'task' found!"
        raise e
      end
    end
    puts "\n BUILD SUCCESSFUL."
    puts "====================================================================="
  end

  # Methode qui permet de construire une tache de nom donne
  def self.build_task task, project_name, scm, auto_install, proxy_option
    case task
    # ==========================================================================
    #  Construction de la tache dcov (couverture rdoc)
    # ==========================================================================
    when 'dcov'
      # On verifie la presence de dcov
      dcov_version = run_command("gem list dcov")
      if dcov_version.blank?
        if auto_install == "true"
          puts " Installing dcov..."
          dcov_installed = run_command("#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install dcov#{proxy_option}")
          if dcov_installed.index("1 gem installed").nil?
            raise " Install for dcov failed with command '#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install dcov#{proxy_option}'\n BUILD FAILED."
          end
        else
          raise " You don't seem to have dcov installed. You can install it with '#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install dcov#{proxy_option}'.\n BUILD FAILED."
        end
      end
      # On lance la generation
      puts " Building dcov rdoc coverage report..."
      dcov_pass = system("dcov -p app/**/*.rb")
      if !dcov_pass and !File.exist?("./coverage.html")
        raise " Execution of dcov failed with command 'dcov -p app/**/*.rb'.\n BUILD FAILED."
      end
    # ==========================================================================
    #  Construction de la tache rcov (couverture des tests sur le code)
    # ==========================================================================
    when 'rcov'
      # On verifie la presence de rcov
      rcov_version = run_command("gem list rcov")
      if rcov_version.blank?
        if auto_install == "true"
          puts " Installing rcov..."
          rcov_installed = run_command("#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install rcov#{proxy_option}")
          if rcov_installed.index("1 gem installed").nil?
            raise " Install for rcov failed with command '#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install rcov#{proxy_option}'\n BUILD FAILED."
          end
        else
          raise " You don't seem to have rcov installed. You can install it with '#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install rcov#{proxy_option}'.\n BUILD FAILED."
        end
      end
      # On lance la generation
      puts " Building rcov code coverage report..."
      rcov_pass = run_command("rcov --rails --exclude rcov,rubyforge test/rcov*.rb")
      if rcov_pass.index("Finished in").nil?
        raise " Execution of rcov failed with command 'rcov --rails --exclude rcov,rubyforge test/rcov*.rb'.\n BUILD FAILED."
      end
      # On recupere le rapport genere
      Dir.mkdir "#{WORK_DIR}/rcov"
      FileUtils.mv("coverage", "#{WORK_DIR}/rcov/")
    # ==========================================================================
    #  Construction de la tache rdoc (apidoc)
    # ==========================================================================
    when 'rdoc'
      # On lance la generation
      puts " Building rdoc api and rdoc generation report..."
      File.delete("rdoc.log") if File.exist?("rdoc.log")
      rdoc_pass = system("rake doc:reapp > rdoc.log")
      if !rdoc_pass
        raise " Execution of rdoc failed with command 'rake doc:reapp'.\n BUILD FAILED."
      end
      # On recupere la documentation et le fichier de log generes
      Dir.mkdir "#{WORK_DIR}/rdoc"
      FileUtils.mv("doc/app/", "#{WORK_DIR}/rdoc/")
      FileUtils.mv("rdoc.log", "#{WORK_DIR}/rdoc/")
    # ==========================================================================
    #  Construction de la tache flog (complexite du code ruby)
    # ==========================================================================
    when 'flog'
      # On verifie la presence de flog
      flog_version = `gem list|grep flog`
      if flog_version.empty?
        if auto_install == "true"
          puts " Installing flog..."
          flog_installed = system("sudo gem install flog")
          if !flog_installed
            raise " Install for flog failed with command 'sudo gem install flog'\n BUILD FAILED."
          end
        else
          raise " You don't seem to have flog installed. You can install it with 'gem install flog'.\n BUILD FAILED."
        end
      end
      # On lance la generation
      puts " Building flog code complexity analysis report..."
      flog_pass = system("find app -name \\*.rb | xargs flog > flog.log")
      if !flog_pass
        raise " Execution of flog failed with command 'find app -name \\*.rb | xargs flog > flog.log'.\n BUILD FAILED."
      end
      # On recupere le fichier de log genere
      Dir.mkdir "#{WORK_DIR}/flog"
      `cp flog.log #{WORK_DIR}/flog`
    # ==========================================================================
    #  Construction de la tache kwala (métriques et rapports de qualite ruby)
    # ==========================================================================
    when 'kwala'
      # On verifie la presence de kwala
      kwala_result = `kwala`
      if kwala_result.empty?
        raise " You don't seem to have kwala installed. please go first to http://kwala.rubyforge.org/."
      end
      # On lance la generation
      puts " Building kwala code reports..."
      actions = ""
      task.params.actions.each('action') do |action|
        actions = actions + " -a #{action.text}"
      end
      if actions.empty?
        raise " You must specify at least one action for your kwala task."
      end
      kwala_pass = system("kwala -p #{project_name} -d . -o #{WORK_DIR}/kwala #{actions}")
      if !kwala_pass
        raise " Execution of kwala failed with command 'kwala -p #{project_name} -d . -o #{WORK_DIR}/kwala #{actions}'.\n BUILD FAILED."
      end
    # ==========================================================================
    #  Construction de la tache railroad (graphes modeles et controleurs)
    # ==========================================================================
    when 'railroad'
      # On verifie la presence de railroad
      railroad_version = `gem list|grep railroad`
      if railroad_version.empty?
        if auto_install == "true"
          puts " Installing railroad..."
          railroad_installed = system("sudo gem install railroad")
          if !railroad_installed
            raise " Install for railroad failed with command 'sudo gem install railroad'\n BUILD FAILED."
          end
        else
          raise " You don't seem to have railroad installed. You can install it with 'gem install railroad'.\n BUILD FAILED."
        end
      end
      # On lance la generation
      puts " Building railroad graphs..."
      if task.params.generate.text == "all" or task.params.generate.text == "models"
        railroad_pass = system("railroad -i -a -M | dot -Tsvg > models.svg")
        if !railroad_pass
          raise " Execution of railroad failed with command 'railroad -i -a -M | dot -Tsvg > models.svg'.\n BUILD FAILED."
        end
      end
      if task.params.generate.text == "all" or task.params.generate.text == "controllers"
        railroad_pass = system("railroad -i -a -C | dot -Tsvg > controllers.svg")
        if !railroad_pass
          raise " Execution of railroad failed with command 'railroad -i -a -C | dot -Tsvg > controllers.svg'.\n BUILD FAILED."
        end
      end
      # TODO Verifier tout ceci.
      `for file in *.svg
do
    /bin/mv $file $file.old
    sed 's/font-size:14.00/font-size:11.00/g' < $file.old > $file
done
rm *.svg.old`
      # On recupere les graphes generes
      Dir.mkdir "#{WORK_DIR}/railroad"
      `cp *.svg #{WORK_DIR}/railroad`
    # ==========================================================================
    #  Construction de la tache stress (montee en charge de l'application)
    # ==========================================================================
    when 'httperf'
      # On verifie la presence de httperf
      httperf_version = `httperf --version`
      if httperf_version.empty?
        raise " You don't seem to have httperf installed. You can install it whith 'sudo apt-get install httperf', or go download it on http://www.hpl.hp.com/research/linux/httperf/."
      end
      # On verifie la presence de mongrel (on ne va pas stresser l'application
      # avec webrick, tout de meme).
      mongrel_version = `gem list|grep mongrel`
      if mongrel_version.empty? or mongrel_version.match(/mongrel /).nil?
        if auto_install == "true"
          puts " Installing Mongrel..."
          mongrel_installed = system("sudo gem install railroad")
          if !mongrel_installed
            raise " Install for Mongrel failed with command 'sudo gem install mongrel'\n BUILD FAILED."
          end
        else
          raise " You don't seem to have mongrel installed. You can install it with 'gem install mongrel'.\n BUILD FAILED."
        end
      end
      Dir.mkdir "#{WORK_DIR}/httperf"
      # On demarre la ou les instances de mongrel
      puts " Starting server instance(s) for application stressing..."
      task.params.ports.each('port') do |port|
        mongrel_start_log = `mongrel_rails start -e production -l #{WORK_DIR}/httperf/mongrel_#{port.text}.log -p #{port.text} -d -P log/mongrel_#{port.text}.pid`
        if !mongrel_start_log.empty?
          raise "BUILD FAILED."
        end
      end
      fork { sleep(3) }
      # On stresse l'application
      if File.exist?("httperf.html")
        File.delete("httperf.html")
      end
      task.params.processes.each('process') do |process|
        params = ""
        if !process['requests'].nil? and !process['requests'].empty?
          params = params + " --num-conns=#{process['requests']}"
        end
        if !process['sessions'].nil? and !process['sessions'].empty?
          params = params + " --wsess=#{process['sessions']}"
        end
        if !process['rate'].nil? and !process['rate'].empty?
          params = params + " --rate=#{process['rate']}"
        end
        if !process['timeout'].nil? and !process['timeout'].empty?
          params = params + " --timeout=#{process['timeout']}"
        end
        httperf_results = `httperf --port #{process['port']} --server 127.0.0.1 --uri #{process['url']}#{params}`
        h = File.open("httperf.html", "a")
        h.write(HttperfFormatter.new(httperf_results, process.description.text).to_html)
        h.close
      end
      # On arrete la ou les instances de mongrel
      puts "\n Stopping server instance(s)..."
      task.params.ports.each('port') do |port|
        puts `mongrel_rails stop -P log/mongrel_#{port.text}.pid`
      end
    # ==========================================================================
    #  Construction de la tache heckle (eprouvage des tests)
    # ==========================================================================
    when 'heckle'
      # On verifie la presence de heckle
      heckle_result = `heckle`
      if heckle_result.empty?
        if auto_install == "true"
          puts " Installing heckle..."
          heckle_installed = system("sudo gem install heckle")
          if !heckle_installed
            raise " Install for heckle failed with command 'sudo gem install heckle'\n BUILD FAILED."
          end
        else
          raise " You don't seem to have heckle installed. You can install it with 'gem install heckle'.\n BUILD FAILED."
        end
      end
      # On lance la generation
      puts " Building heckle reports..."
      heckle_report = File.open("heckle.html", "w")
      heckle_report.write(HeckleFormatter.new(task.params).to_html)
      heckle_report.close
    # ==========================================================================
    #  Construction de la tache stats (statistiques code Ruby)
    # ==========================================================================
    when 'stats'
      # On lance la generation
      puts " Building stats report..."
      stats_result = `rake stats`
      stats_report = File.open("stats.html", "w")
      stats_report.write(StatsFormatter.new(stats_result).to_html)
      stats_report.close
    # ==========================================================================
    #  Construction de la tache tests (tests unitaires, toutes categories)
    # ==========================================================================
    when 'tests'
      # On lance la generation
      puts " Building tests report..."
      if File.exist?("tests.html")
        File.delete("tests.html")
      end
      tests_report = File.open("tests.html", "a")
      tests_report.write(TestsFormatter.new(task.params).to_html)
      tests_report.close
    # ==========================================================================
    #  Construction de la tache zentest (manques dans les tests unitaires)
    # ==========================================================================
    when 'zentest'
      # On vérifie la presence de ZenTest
      zentest_result = `zentest`
      if zentest_result.empty?
        if auto_install == "true"
          puts " Installing ZenTest..."
          zentest_installed = system("sudo gem install ZenTest")
          if !zentest_installed
            raise " Install for ZenTest failed with command 'sudo gem install ZenTest'.\n BUILD FAILED."
          end
        else
          raise " You don't seem to have ZenTest installed. You can install it with 'gem install ZenTest'.\n BUILD FAILED."
        end
      end
      # On lance la generation
      puts " Building ZenTest report..."
      zentest_report = File.open("zentest.html", "w")
      zentest_report.write(ZenTestFormatter.new(task.params).to_html)
      zentest_report.close
    # ==========================================================================
    #  Construction de la tache capistrano (logs des deploiements effectues)
    # ==========================================================================
    when 'capistrano'
      # On vérifie la presence de Capistrano
      cap_result = `cap --version`
      if cap_result.empty?
        raise " You don't seem to have Capistrano installed. You can install it with 'gem install capistrano'."
      end
      # On lance la generation
      puts " Building Capistrano log report..."
      capistrano_report = File.open("capistrano.html", "w")
      task.params.each('runner') do |runner|
        if File.exist?("capistrano.log")
          File.delete("capistrano.log")
        end
        capistrano_pass = system("cap #{runner['task']} 2> capistrano.log")
        if !capistrano_pass
          capistrano_report.close
          raise(" Capistrano deployment with command \'cap #{runner['task']}\' did not pass.\n BUILD FAILED.")
        else
          capistrano_report.write(CapistranoFormatter.new(runner['task'],File.read("capistrano.log")).to_html)
        end
      end
      capistrano_report.close
    # ===========================================================================
    #  Construction de la tache changelog (changements du referentiel de sources)
    # ===========================================================================
    when 'changelog'
      unless scm.repository_type.text == "svn"
        raise " Only Subversion is supported at the moment. You need to deactivate the 'changelog' task.\n BUILD FAILED."
      end
      # On verifie l'existence de Subversion
      svn_version = `svn --version`
      if svn_version.empty?
        raise " Subversion don't seem to be installed. Go see Subversion website on http://subversion.tigris.org.\n BUILD FAILED"
      end
      # Gestion de la derniere version
      # 1 - On verifie le repertoire home/continuous4r
      unless File.exist?(ENV["HOME"] + "/.continuous4r")
        Dir.mkdir(ENV["HOME"] + "/.continuous4r")
      end
      # 2 - On verifie le numero de version
      scm_current_version = scm['min_revision']
      scm_current_version ||= "1"
      scm_last_version = 1
      if File.exist?(ENV["HOME"] + "/.continuous4r/#{project_name}_#{scm.repository_type.text}.version")
        scm_current_version = File.read(ENV["HOME"] + "/.continuous4r/#{project_name}_#{scm.repository_type.text}.version")
      end
      # 3 - On extrait les informations du referentiel
      case scm.repository_type.text
      when "svn"
        scm_last_version = SubversionExtractor.extract_changelog(scm_current_version.to_i,scm,"changelog.html")
      end
      # 4 - On ecrit le nouveau numero de revision
      rev_file = File.open(ENV["HOME"] + "/.continuous4r/#{project_name}_#{scm.repository_type.text}.version","w")
      rev_file.write(scm_last_version)
      rev_file.close
    else
      raise " Don't know how to build '#{task['name']}' task."
    end
  end

  # Methode qui permet de construire une page avec eruby, et de lever une exception au besoin
  def self.erb_run page
    page_file = File.open("#{WORK_DIR}/#{page}.html", "w")
    erb = ERB.new(File.read("#{File.dirname(__FILE__)}/site/header.rhtml"))
    page_file.write(erb.result)
#    if !system(command)
#      raise "BUILD FAILED."
#    end
    erb = ERB.new(File.read("#{File.dirname(__FILE__)}/site/menu-#{page}.rhtml"))
    page_file.write(erb.result)
    erb = ERB.new(File.read("#{File.dirname(__FILE__)}/site/body-#{page}.rhtml"))
    page_file.write(erb.result)
    page_file.close
  end

  # Methode qui permet de lancer une ligne de commande et de renvoyer son resultat
  def self.run_command(cmd)
    if Config::CONFIG['host_os'] =~ /mswin/
      `cmd.exe /C #{cmd}`
    else
      `#{cmd}`
    end
  end
end
