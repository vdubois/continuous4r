# ==========================================================================
#  Construction de la tache rcov (couverture des tests sur le code)
#  author: Vincent Dubois
#  date: 06 fevrier 2009
# ==========================================================================
class RcovBuilder
  include Utils

  # Implementation de la construction de la tache
  def build(project_name, auto_install, proxy_option)
      # On verifie la presence de rcov
      Utils.verify_gem_presence("rcov", auto_install, proxy_option)
      # On lance la generation
      puts " Building rcov code coverage report..."
      rcov_pass = Utils.run_command("rcov --rails --exclude rcov,rubyforge,builder,mime-types,xml-simple test/rcov*.rb")
      if rcov_pass.index("Finished in").nil?
        raise " Execution of rcov failed with command 'rcov --rails --exclude rcov,rubyforge test/rcov*.rb'.\n BUILD FAILED."
      end
      # On recupere le rapport genere
      Dir.mkdir "#{Continuous4r::WORK_DIR}/rcov"
      FileUtils.mv("coverage", "#{Continuous4r::WORK_DIR}/rcov/")
  end

  # Methode qui permet d'extraire le pourcentage de qualite extrait d'un builder
  def quality_percentage
    require 'hpricot'
    doc = Hpricot(File.read("#{Continuous4r::WORK_DIR}/rcov/coverage/index.html"))
    (doc/'tt[@class^="coverage_code"]')[0].inner_text.split(/%/)[0]
  end

  # Nom de l'indicateur de qualite
  def quality_indicator_name
    "tests coverage"
  end
end