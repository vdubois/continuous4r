# ==========================================================================
#  Construction de la tache flog (complexite du code ruby)
#  author: Vincent Dubois
#  date: 06 fevrier 2009
# ==========================================================================
class FlogBuilder
  include Utils

  # Implementation de la construction de la tache
  def build(project_name, scm, auto_install, proxy_option)
    # On verifie la presence de flog
    Utils.verify_gem_presence("flog", auto_install, proxy_option)
    # On verifie la presence de metric_fu
    metric_fu_version = Utils.run_command("gem list jscruggs-metric_fu")
    if metric_fu_version.blank?
      if auto_install == "true"
        puts " Installing metric_fu..."
        metrics_fu_installed = Utils.run_command("#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install jscruggs-metric_fu#{proxy_option} -s http://gems.github.com/")
        if metrics_fu_installed.index("1 gem installed").nil?
          raise " Install for metrics_fu failed with command '#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install jscruggs-metric_fu#{proxy_option} -s http://gems.github.com/'\n BUILD FAILED."
        end
      else
        raise " You don't seem to have metric_fu installed. You can install it with '#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install jscruggs-metric_fu#{proxy_option} -s http://gems.github.com/'.\n BUILD FAILED."
      end
    end
    # On lance la generation (produite dans tmp/metric_fu/flog)
    puts " Building flog report..."
    system("rake metrics:flog:all")
    if !File.exist?("tmp/metric_fu/flog/index.html")
      raise " Execution of flog with the metric_fu gem failed.\n BUILD FAILED."
    end
    # On recupere les fichiers générés
    FileUtils.mv("tmp/metric_fu/flog", "#{Continuous4r::WORK_DIR}/flog")
  end
end
