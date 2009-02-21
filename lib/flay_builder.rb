# ==========================================================================
#  Construction de la tache flay (doublons dans du code ruby)
#  author: Vincent Dubois
#  date: 08 fevrier 2009
# ==========================================================================
class FlayBuilder
  include Utils

  # Implementation de la construction de la tache
  def build(project_name, auto_install, proxy_option)
    # On verifie la presence de flay
    Utils.verify_gem_presence("flay", auto_install, proxy_option)
    # On lance la generation (produite dans tmp/metric_fu/flay)
    puts " Building flay report..."
    ENV['HOME'] = ENV['USERPROFILE'] if Config::CONFIG['host_os'] =~ /mswin/ and ENV['HOME'].nil?
    files = Array.new
    files << Dir.glob("app/**/*.rb")
    files << Dir.glob("lib/**/*.rb")
    files << Dir.glob("test/**/*.rb")
    files.flatten!
    flay_command = "flay"
    files.each do |file|
      flay_command += " '#{file}'"
    end
    flay_result = Utils.run_command(flay_command)
    matches = flay_result.chomp.split("\n\n").map{|m| m.split("\n  ") }
    FileUtils.mkdir("#{Continuous4r::WORK_DIR}/flay")
    flay_file = File.open("#{Continuous4r::WORK_DIR}/flay/index.html","w")
    matches.each_with_index do |match, count|
      flay_file.write("<tr class='#{count % 2 == 0 ? "a" : "b"}'><td>")
      match[1..-1].each do |filename|
        flay_file.write("<a href='xdoclet/#{filename.split(":")[0].gsub(/\//,'_')}.html##{filename.split(":")[1]}' target='_blank'>#{filename}</a><br/>")
      end
      flay_file.write("</td><td>#{match.first}</td></tr>")
    end
    flay_file.close
  end
end
