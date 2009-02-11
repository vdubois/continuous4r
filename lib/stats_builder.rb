# ==========================================================================
#  Construction de la tache stats (statistiques du code Ruby)
#  author: Vincent Dubois
#  date: 06 fevrier 2009
# ==========================================================================
class StatsBuilder
  include Utils

  # Implementation de la construction de la tache
  def build(project_name, scm, auto_install, proxy_option)
    # On lance la generation
    puts " Building stats report..."
    stats_result = Utils.run_command("rake stats")
    stats_report = File.open("#{Continuous4r::WORK_DIR}/stats_body.html", "w")
    stats_report.write(StatsFormatter.new(stats_result).to_html)
    stats_report.close
  end
end
