# ==========================================================================
#  Construction de la tache flay (doublons dans du code ruby)
#  author: Vincent Dubois
#  date: 08 fevrier 2009
# ==========================================================================
class FlayBuilder
  include Utils

  # Implementation de la construction de la tache
  def build(project_name, scm, auto_install, proxy_option)
    # On verifie la presence de flay
    Utils.verify_gem_presence("flay", auto_install, proxy_option)
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
