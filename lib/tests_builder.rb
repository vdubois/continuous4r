# ==========================================================================
#  Construction de la tache test (test unitaires du code ruby)
#  author: Vincent Dubois
#  date: 11 fevrier 2009
# ==========================================================================
class TestsBuilder
  include Utils

  # Prérequis à la tâche
  def prerequisite_met?
    Dir.glob("test/**/*_test.rb").length > 0
  end

  # Dans le cas de l'erreur de prérequis
  def prerequisite_unmet_message
    " No tests found. The 'tests' task will be empty."
  end

  # Implementation de la construction de la tache
  def build(project_name, auto_install, proxy_option)
    # On lance la generation
    puts " Building tests report..."
    if File.exist?("#{Continuous4r::WORK_DIR}/tests-run.html")
      File.delete("#{Continuous4r::WORK_DIR}/tests-run.html")
    end
    tests_report = File.open("#{Continuous4r::WORK_DIR}/tests-run.html", "w")
    html = TestsFormatter.new.to_html
    tests_report.write(html)
    tests_report.close
  end
end