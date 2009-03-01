# ==========================================================================
#  Construction de la tache reek (imperfections dans le code Ruby)
#  author: Vincent Dubois
#  date: 08 fevrier 2009
# ==========================================================================
require 'reek'
require 'reek/options'
require 'reek/smells/smells'

module Reek

  SMELLS = {
    :defn => [
      Smells::ControlCouple,
      Smells::UncommunicativeName,
      Smells::LongMethod,
      Smells::UtilityFunction,
      Smells::FeatureEnvy
      ]
  }
end

class ReekBuilder
  include Utils

  # Implementation de la construction de la tache
  def build(project_name, auto_install, proxy_option)
    # On verifie la presence de reek
    Utils.verify_gem_presence("reek", auto_install, proxy_option)
    # On lance la generation
    puts " Building reek report..."
    files = Array.new
    files << Dir.glob("app/**/*.rb")
    files << Dir.glob("lib/**/*.rb")
    files << Dir.glob("test/**/*.rb")
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
    matches.each do |match|
      smells = Array.new
      match[1..-1].each do |filename|
        if filename.index("[Duplication]").nil?
          #reek_file.write("#{filename}<br/>")
          smells << filename
        end
      end
      if smells.length > 0
        reek_file.write("<tr class='#{count % 2 == 0 ? "a" : "b"}'>")
        reek_file.write("<td><a href='xdoclet/#{match.first.split("\"")[1].gsub(/\//,'_')}.html' target='_blank'>#{match.first.split("\"")[1]}</a> -- #{smells.length} warning#{"s" if smells.length > 1}</td><td>")
        smells.each do |smell|
          reek_file.write("#{smell}<br/>")
        end
        reek_file.write("</td></tr>")
        count += 1
      end
    end
    reek_file.close
  end
end
