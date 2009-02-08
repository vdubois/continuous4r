# ==========================================================================
#  Construction de la tache flay (doublons dans du code ruby)
#  author: Vincent Dubois
#  date: 08 fevrier 2009
# ==========================================================================
class ReekBuilder
  include Utils

  # Implementation de la construction de la tache
  def build(project_name, scm, auto_install, proxy_option)
    # On verifie la presence de flog
    reek_version = Utils.run_command("gem list reek")
    if reek_version.blank?
      if auto_install == "true"
        puts " Installing reek..."
        reek_installed = Utils.run_command("#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install reek#{proxy_option}")
        if reek_installed.index("installed").nil?
          raise " Install for reek failed with command '#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install reek#{proxy_option}'\n BUILD FAILED."
        end
      else
        raise " You don't seem to have reek installed. You can install it with '#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install reek#{proxy_option}'.\n BUILD FAILED."
      end
    end
    # On lance la generation (produite dans tmp/metric_fu/reek)
    puts " Building reek report..."
    system("rake metrics:reek")
    if !File.exist?("tmp/metric_fu/reek/index.html")
      raise " Execution of reek with the metric_fu gem failed.\n BUILD FAILED."
    end
    # On recupere les fichiers générés
    FileUtils.mv("tmp/metric_fu/reek", "#{Continuous4r::WORK_DIR}/reek")
  end
end
