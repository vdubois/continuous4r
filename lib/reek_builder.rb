# ==========================================================================
#  Construction de la tache reek (imperfections dans le code Ruby)
#  author: Vincent Dubois
#  date: 08 fevrier 2009
# ==========================================================================
class ReekBuilder
  include Utils

  # Implementation de la construction de la tache
  def build(project_name, scm, auto_install, proxy_option)
    # On verifie la presence de reek
    Utils.verify_gem_presence("reek", auto_install, proxy_option)
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
