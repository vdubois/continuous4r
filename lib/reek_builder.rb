# ==========================================================================
#  Construction de la tache reek (imperfections dans le code Ruby)
#  author: Vincent Dubois
#  date: 08 fevrier 2009
# ==========================================================================
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
    matches.each_with_index do |match, count|
      reek_file.write("<tr class='#{count % 2 == 0 ? "a" : "b"}'>")
      reek_file.write("<td><a href='xdoc/#{match.first.split("\"")[1].gsub(/\//,'_')}.html' target='_blank'>#{match.first.split("\"")[1]}</a> #{match.first.split("\"")[2]}</td><td>")
      match[1..-1].each do |filename|
        reek_file.write("#{filename}<br/>")
      end
      reek_file.write("</td></tr>")
    end
    reek_file.close
  end
end
