require 'utils.rb'

# ==========================================================================
#  Construction de la tache rcov (couverture des tests sur le code)
#  author: Vincent Dubois
#  date: 06 fevrier 2009
# ==========================================================================
class RcovBuilder
  include Utils

  # Implementation de la construction de la tache
  def build(project_name, scm, auto_install, proxy_option)
      # On verifie la presence de rcov
      rcov_version = Utils.run_command("gem list rcov")
      if rcov_version.blank?
        if auto_install == "true"
          puts " Installing rcov..."
          rcov_installed = Utils.run_command("#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install rcov#{proxy_option}")
          if rcov_installed.index("1 gem installed").nil?
            raise " Install for rcov failed with command '#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install rcov#{proxy_option}'\n BUILD FAILED."
          end
        else
          raise " You don't seem to have rcov installed. You can install it with '#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install rcov#{proxy_option}'.\n BUILD FAILED."
        end
      end
      # On lance la generation
      puts " Building rcov code coverage report..."
      rcov_pass = Utils.run_command("rcov --rails --exclude rcov,rubyforge test/rcov*.rb")
      if rcov_pass.index("Finished in").nil?
        raise " Execution of rcov failed with command 'rcov --rails --exclude rcov,rubyforge test/rcov*.rb'.\n BUILD FAILED."
      end
      # On recupere le rapport genere
      Dir.mkdir "#{Continuous4r::WORK_DIR}/rcov"
      FileUtils.mv("coverage", "#{Continuous4r::WORK_DIR}/rcov/")
  end
end