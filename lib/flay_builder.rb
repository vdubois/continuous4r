# ==========================================================================
#  Construction de la tache flay (doublons dans du code ruby)
#  author: Vincent Dubois
#  date: 08 fevrier 2009
# ==========================================================================
class FlayBuilder
  include Utils

  # Implementation de la construction de la tache
  def build(project_name, scm, auto_install, proxy_option)
    # On verifie la presence de flog
    flay_version = Utils.run_command("gem list flay")
    if flay_version.blank?
      if auto_install == "true"
        puts " Installing flay..."
        flay_installed = Utils.run_command("#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install flay#{proxy_option}")
        if flay_installed.index("installed").nil?
          raise " Install for flay failed with command '#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install flay#{proxy_option}'\n BUILD FAILED."
        end
      else
        raise " You don't seem to have flay installed. You can install it with '#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install flay#{proxy_option}'.\n BUILD FAILED."
      end
    end
    # On lance la generation (produite dans tmp/metric_fu/flay)
    puts " Building flay report..."
    system("rake metrics:flay")
    if !File.exist?("tmp/metric_fu/flay/index.html")
      raise " Execution of flay with the metric_fu gem failed.\n BUILD FAILED."
    end
    # On recupere les fichiers générés
    FileUtils.mv("tmp/metric_fu/flay", "#{Continuous4r::WORK_DIR}/flay")
  end
end
