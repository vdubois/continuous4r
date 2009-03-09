# ==========================================================================
#  Construction de la tache saikuro (complexite cyclomatique du code)
#  author: Vincent Dubois
#  date: 08 fevrier 2009
# ==========================================================================
class SaikuroBuilder

  # Implementation de la construction de la tache
  def build(project_name, auto_install, proxy_option)
    # On verifie la presence de saikuro
    Utils.verify_gem_presence("Saikuro", auto_install, proxy_option)
    # On lance la generation
    puts " Building saikuro report..."
    puts Utils.run_command("saikuro -c -i app -i lib -i test -y 0 -w 5 -e 7 -o #{Continuous4r::WORK_DIR}/saikuro")
    if !File.exist?("#{Continuous4r::WORK_DIR}/saikuro/index_cyclo.html")
      raise " Execution of saikuro with the metric_fu gem failed.\n BUILD FAILED."
    end
    require 'hpricot'
    doc = Hpricot(File.read("#{Continuous4r::WORK_DIR}/saikuro/index_cyclo.html"))
    classes_with_errors = Array.new
    classes_with_warnings = Array.new
    doc.search("//tr") do |tr|
      tds = tr.search("td")
      if tds.length > 0 and tds[2]['class'] == "error" and !(classes_with_errors.include?(tds[0].inner_text))
        classes_with_errors << tds[0].inner_text
      elsif tds.length > 0 and tds[2]['class'] == "warning" and !(classes_with_warnings.include?(tds[0].inner_text))
        classes_with_warnings << tds[0].inner_text
      end
    end
    files = Array.new
    files << Dir.glob("app/**/*.rb")
    files << Dir.glob("lib/**/*.rb")
    files << Dir.glob("test/**/*.rb")
    files.flatten!
    @percent = 100.0 - (((classes_with_errors.length + (classes_with_warnings.length * 0.5)) * 100.0) / files.length.to_f)
    @@percent = @percent
  end

  # Methode de classe pour recuperer l'indicateur de qualite
  def self.percent
    @@percent
  end
  
  # Methode qui permet d'extraire le pourcentage de qualite extrait d'un builder
  def quality_percentage
    @percent
  end

  # Nom de l'indicateur de qualite
  def quality_indicator_name
    "cyclomatic complexity"
  end
end