# ==========================================================================
#  Construction de la tache reek (imperfections dans le code Ruby)
#  author: Vincent Dubois
#  date: 08 fevrier 2009
# ==========================================================================
class ReekBuilder

  # Implementation de la construction de la tache
  def build(project_name, auto_install, proxy_option)
    # On verifie la presence de reek
    Utils.verify_gem_presence("reek", auto_install, proxy_option)
    # On lance la generation
    puts " Building reek report..."
    files = Array.new
    files << Dir.glob("app/controllers/*.rb")
    files << Dir.glob("app/helpers/*.rb")
    files << Dir.glob("app/models/*.rb")
    files << Dir.glob("lib/**/*.rb")
    files << Dir.glob("test/**/*.rb")
    files << Dir.glob("spec/**/*.rb")
    files.flatten!
    reek_command = "reek"
    files.each do |file|
      reek_command += " '#{file}'"
    end
    reek_result = Utils.run_command(reek_command)
    matches = reek_result.chomp.split("\n\n").map{|m| m.split("\n") }
    FileUtils.mkdir("#{Continuous4r::WORK_DIR}/reek")
    reek_file = File.open("#{Continuous4r::WORK_DIR}/reek/index.html","w")
    count = 0
    score = 0.0
    matches.each do |match|
      smells = Array.new
      match[1..-1].each do |filename|
        smells << filename if filename.index("[Duplication]").nil?
      end
      if smells.length > 0
        reek_file.write("<tr class='#{count % 2 == 0 ? "a" : "b"}'>")
        reek_file.write("<td><a href='xdoclet/#{match.first.split("\"")[1].gsub(/\//,'_')}.html' target='_blank'>#{match.first.split("\"")[1]}</a> -- #{smells.length} warning#{"s" if smells.length > 1}</td><td>")
        if smells.length > 10
          score += 1.0
        else
          score += 0.5
        end
        smells.each do |smell|
          reek_file.write("#{smell}<br/>")
        end
        reek_file.write("</td></tr>")
        count += 1
      end
    end
    reek_file.close
    @percent = 100 - ((score * files.length) / 100)
    @@percent = @percent
  end

  # Methode de classe pour recuperer l'indicateur de qualite
  def self.percent
    @@percent
  end
  
  # Methode qui permet d'extraire le pourcentage de qualité extrait d'un builder
  def quality_percentage
    @percent
  end

  # Nom de l'indicateur de qualité
  def quality_indicator_name
    "code smells"
  end
end
