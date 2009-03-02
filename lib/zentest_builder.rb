# ==========================================================================
#  Construction de la tache zentest (manques dans les tests unitaires)
#  author: Vincent Dubois
#  date: 12 fevrier 2009
# ==========================================================================
class ZentestBuilder
  include Utils

  # Prérequis à la tâche
  def prerequisite_met?
    Dir.glob("test/**/*.rb").length > 0
  end

  # Dans le cas de l'erreur de prérequis
  def prerequisite_unmet_message
    " No tests found. The 'ZenTest' task will be empty."
  end

  # Implementation de la construction de la tache
  def build(project_name, auto_install, proxy_option)
    # On verifie la presence de ZenTest
    Utils.verify_gem_presence("ZenTest", auto_install, proxy_option)
    # On lance la generation
    puts " Building ZenTest report..."
    zentest_report = File.open("#{Continuous4r::WORK_DIR}/zentest-body.html", "w")
    zentest_report.write(ZenTestFormatter.new.to_html)
    zentest_report.close
  end
end