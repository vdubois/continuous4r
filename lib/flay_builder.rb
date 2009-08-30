require 'utils.rb'

# ==========================================================================
#  Construction de la tache flay (doublons dans du code ruby)
#  author: Vincent Dubois
#  date: 08 fevrier 2009
# ==========================================================================
class FlayBuilder

  # Implementation de la construction de la tache
  def build(project_name, auto_install, proxy_option)
    # On verifie la presence de flay
    Utils.verify_gem_presence("flay", auto_install, proxy_option)
    # On lance la generation (produite dans tmp/metric_fu/flay)
    puts " Building flay report..."
    ENV['HOME'] = ENV['USERPROFILE'] if Config::CONFIG['host_os'] =~ /mswin/ and ENV['HOME'].nil?
    files = Dir.glob("app/**/*.rb")
    files << Dir.glob("lib/**/*.rb")
    files << Dir.glob("test/**/*.rb")
    files << Dir.glob("spec/**/*.rb")
    files.flatten!
    flay_command = "flay -v"
    files.each do |file|
      flay_command += " '#{file}'"
    end
    flay_result = Utils.run_command(flay_command)
    matches = flay_result.chomp.split("\n\n")
    # Fix for flay 1.2.0 : we delete the score
    matches.delete_at(0)
    FileUtils.mkdir("#{Continuous4r::WORK_DIR}/flay")
    flay_file = File.open("#{Continuous4r::WORK_DIR}/flay/index.html","w")
    class_index = 0
    summary = ""
    duplicate_lines = 0
    matches.each_with_index do |match, index|
      if index % 2 == 0
        flay_file.write("<tr class='#{class_index % 2 == 0 ? "a" : "b"}'>")
        lines = match.split(/$/)
        summary = lines[0]
        flay_file.write("<td>")
        (1..(lines.length - 1)).to_a.each do |line|
          flay_file.write("<a href='xdoclet/#{lines[line].split(":")[1].strip.gsub(/\//,'_')}.html##{lines[line].split(":")[2]}' target='_blank'>#{lines[line].strip}</a><br/>")
        end
        flay_file.write("</td>")
        class_index += 1
      else
        flay_file.write("<td")
        begin
          mass = summary.split(/mass = /)[1].split(/\)/)[0].to_i
        rescue
          mass = summary.split(Regexp.new(" = "))[1].split(/\)/)[0].to_i
        end
        if summary.match(/IDENTICAL/)
          flay_file.write(" style='background-color: orange;' title='Not DRY'")
        elsif mass >= 40
          flay_file.write(" style='background-color: yellow;' title='Not DRY'")
        end
        if summary.match(/IDENTICAL/) or mass >= 40
          match.each do |elem|
            if elem.match(/^A:/) or elem.match(/^ /)
              duplicate_lines += 1
            end
          end
        end
        flay_file.write(">#{summary}<br/><pre>")
        flay_file.write("#{match}</pre></td></tr>")
      end
      require 'hpricot'
      doc = Hpricot(File.read("#{Continuous4r::WORK_DIR}/stats_body.html"))
      tr_arr = doc.search("//tr")
      loc = tr_arr[tr_arr.length-1].search("td")[2].inner_text.strip.to_f
      @dryness = 100.0 - ((duplicate_lines.to_f * 100.0) / loc)
      @@dryness = @dryness
    end
    flay_file.close
  end

  # Methode de classe pour recuperer l'indicateur qualite
  def self.dryness
    @@dryness
  end

  # Methode qui permet d'extraire le pourcentage de qualité extrait d'un builder
  def quality_percentage
    @dryness
  end

  # Nom de l'indicateur de qualité
  def quality_indicator_name
    "DRYness"
  end
end

