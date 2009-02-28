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
    flay_command = "flay -v"
    files.each do |file|
      flay_command += " '#{file}'"
    end
    flay_result = Utils.run_command(flay_command)
    matches = flay_result.chomp.split("\n\n")
    FileUtils.mkdir("#{Continuous4r::WORK_DIR}/flay")
    flay_file = File.open("#{Continuous4r::WORK_DIR}/flay/index.html","w")
    class_index = 0
    summary = ""
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
        flay_file.write("<td#{" style='background-color: orange;' title='Not DRY'" if summary.match(/IDENTICAL/)}>#{summary}<br/><pre>")
        flay_file.write("#{match}</pre></td></tr>")
      end
    end
    flay_file.close
  end
end
