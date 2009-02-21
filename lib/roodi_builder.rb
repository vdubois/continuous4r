# ==========================================================================
#  Construction de la tache roodi (problemes de conception dans le code)
#  author: Vincent Dubois
#  date: 08 fevrier 2009
# ==========================================================================
class RoodiBuilder
  include Utils

  # Implementation de la construction de la tache
  def build(project_name, auto_install, proxy_option)
    # On verifie la presence de roodi
    Utils.verify_gem_presence("roodi", auto_install, proxy_option)
    # On lance la generation
    puts " Building roodi report..."
    files = Array.new
    files << Dir.glob("app/**/*.rb")
    files << Dir.glob("lib/**/*.rb")
    files << Dir.glob("test/**/*.rb")
    files.flatten!
    roodi_command = "roodi"
    files.each do |file|
      roodi_command += " '#{file}'"
    end
    roodi_result = Utils.run_command(roodi_command)
    matches = roodi_result.chomp.split("\n").map{|m| m.split(" - ") }
    FileUtils.mkdir("#{Continuous4r::WORK_DIR}/roodi")
    roodi_file = File.open("#{Continuous4r::WORK_DIR}/roodi/index.html","w")
    matches.each_with_index do |match, count|
      roodi_file.write("<tr class='#{count % 2 == 0 ? "a" : "b"}'>")
      if match.first and match.first.index("Found ").nil?
        roodi_file.write("<td><a href='xdoclet/#{match.first.split(':').first.gsub(/\//,'_')}.html' target='_blank'>#{match.first.split(':').first}</a></td>")
      elsif match.first and !match.first.index("Found ").nil?
        roodi_file.write("<td><b>#{match.first}</b></td>")
      else
        roodi_file.write("<td>&#160;</td>")
      end
      roodi_file.write("<td>#{match[1]}</td></tr>")
    end
    roodi_file.close
  end
end
