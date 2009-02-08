# ==========================================================================
#  Construction de la tache roodi (problemes de conception dans le code)
#  author: Vincent Dubois
#  date: 08 fevrier 2009
# ==========================================================================
class RoodiBuilder
  include Utils

  # Implementation de la construction de la tache
  def build(project_name, scm, auto_install, proxy_option)
    # On verifie la presence de roodi
    Utils.verify_gem_presence("roodi", auto_install, proxy_option)
    # On lance la generation (produite dans tmp/metric_fu/reek)
    puts " Building roodi report..."
    system("rake metrics:roodi")
    if !File.exist?("tmp/metric_fu/roodi/index.html")
      raise " Execution of roodi with the metric_fu gem failed.\n BUILD FAILED."
    end
    # On recupere les fichiers générés
    FileUtils.mv("tmp/metric_fu/roodi", "#{Continuous4r::WORK_DIR}/roodi")
  end
end
