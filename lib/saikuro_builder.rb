# ==========================================================================
#  Construction de la tache saikuro (complexité cyclomatique du code)
#  author: Vincent Dubois
#  date: 08 fevrier 2009
# ==========================================================================
class SaikuroBuilder
  include Utils

  # Implementation de la construction de la tache
  def build(project_name, scm, auto_install, proxy_option)
    # On verifie la presence de saikuro
    saikuro_result = Utils.run_command("saikuro")
    if saikuro_result.index("Usage").nil?
      raise " You don't seem to have saikuro installed please go to http://saikuro.rubyforge.org/ to download it.\n BUILD FAILED."
    end
    # On lance la generation (produite dans tmp/metric_fu/saikuro)
    puts " Building saikuro report..."
    system("rake metrics:saikuro")
    if !File.exist?("tmp/metric_fu/saikuro/index.html")
      raise " Execution of saikuro with the metric_fu gem failed.\n BUILD FAILED."
    end
    # On recupere les fichiers générés
    FileUtils.mv("tmp/metric_fu/saikuro", "#{Continuous4r::WORK_DIR}/saikuro")
  end
end