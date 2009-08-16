# ==========================================================================
#  Construction de la tache stats (statistiques du code Ruby)
#  author: Vincent Dubois
#  date: 06 fevrier 2009
# ==========================================================================
class StatsBuilder
  include Utils

  # Implementation de la construction de la tache
  def build(project_name, auto_install, proxy_option, project_root = '.')
    # On lance la generation
    puts " Building stats report..."
    if File.exists?("app/controllers/")
      stats_result = Utils.run_command("rake stats")
    else
      stats_directories = {
        "Tests" => "test",
        "Application" => "lib"
      }.map {|name, dir| [name, "#{Dir.pwd}/#{dir}"]}
      stats_result = CodeStatistics.new(*stats_directories).to_s
    end
    stats_report = File.open("#{Continuous4r::WORK_DIR}/stats_body.html", "w")
    stats_formatter = StatsFormatter.new(stats_result)
    stats_report.write(stats_formatter.to_html)
    stats_report.close
    @percent = stats_formatter.percent
    @percent = 100.00 if @percent > 100.00
    @@percent = @percent
  end

  # Pourcentage de qualite
  def StatsBuilder.percent
    @@percent
  end

  # Methode qui permet d'extraire le pourcentage de qualité extrait d'un builder
  def quality_percentage
    @percent
  end

  # Nom de l'indicateur de qualité
  def quality_indicator_name
    "code-to-test ratio"
  end
end

