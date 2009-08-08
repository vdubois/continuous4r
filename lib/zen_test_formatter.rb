require 'rubygems'
# =====================================================
# Classe de formatage des resultats renvoyes par les
# differents resultats de ZenTest
# Author: Vincent Dubois
# =====================================================
class ZenTestFormatter

  # Methode qui permet de fabriquer le flux HTML a partir des flux console
  # de ZenTest
  def to_html
    files_controllers = files_models = Array.new
    files_controllers << Dir.glob("app/controllers/*_controller.rb")
    files_controllers.flatten!
    files_models << Dir.glob("app/models/*.rb")
    files_models.flatten!
    html = "<table class='bodyTable'><thead><th>Element</th><th>Pass</th><th>Errors</th><th>Generated class</th></thead><tbody>"
    i = 0
    files_controllers.each do |runner|
      ['functional','integration'].each do |test_type|
        if File.exist?("#{RAILS_ROOT}/test/#{test_type}/#{runner.split("/")[2].gsub(Regexp.new(".rb"),"_test.rb")}")
          puts " Running ZenTest on #{runner} against test/#{test_type}/#{runner.split("/")[2].gsub(Regexp.new(".rb"),"_test.rb")}..."
          Utils.run_command("zentest -r #{runner} test/#{test_type}/#{runner.split("/")[2].gsub(Regexp.new(".rb"),"_test.rb")} > #{Continuous4r::WORK_DIR}/zentest.log")
          file_content = File.read("#{Continuous4r::WORK_DIR}/zentest.log")
          file_lines = file_content.split(/$/)
          start_line = 0
          next if file_lines[start_line].nil?
          html += "<tr class='#{ i % 2 == 0 ? 'a' : 'b'}'>"
          html += "<td><a href='xdoclet/#{runner.gsub(/\//,'_')}.html' target='_blank'>#{runner}</a><br/><strong>run against</strong><br/><a href='xdoclet/#{"test/#{test_type}/#{runner.split("/")[2].gsub(Regexp.new(".rb"),"_test.rb")}".gsub(/\//,'_')}.html' target='_blank'>test/#{test_type}/#{runner.split("/")[2].gsub(Regexp.new(".rb"),"_test.rb")}</a></td>"
          while file_lines[start_line].index("Code Generated by ZenTest").nil?
            start_line = start_line + 1
          end
          end_line = start_line
          while file_lines[end_line].index("Number of errors detected").nil?
            end_line = end_line + 1
          end
          number_of_errors = file_lines[end_line][29..(file_lines[end_line].length - 1)]
          end_line = end_line - 1
          html = html + "<td style='text-align: center;'><img src='images/icon_#{(number_of_errors.to_i == 0) ? 'success' : 'error'}_sml.gif'/></td>"
          html = html + "<td style='text-align: center;'>#{number_of_errors}</td>"
          html = html + "<td style='width: 75%;'><pre style='font-family: Courier New; font-size: 11px;'>"
          (start_line..end_line).to_a.each do |index|
            html = html + file_lines[index]
          end
          html = html + "</pre></td></tr>"
          i = i + 1
        end
      end
    end
    files_models.each do |runner|
      if File.exist?("#{RAILS_ROOT}/test/unit/#{runner.split("/")[2].gsub(Regexp.new(".rb"),"_test.rb")}")
        puts " Running ZenTest on #{runner} against test/unit/#{runner.split("/")[2].gsub(Regexp.new(".rb"),"_test.rb")}..."
        Utils.run_command("zentest -r #{runner} test/unit/#{runner.split("/")[2].gsub(Regexp.new(".rb"),"_test.rb")} > #{Continuous4r::WORK_DIR}/zentest.log")
        file_content = File.read("#{Continuous4r::WORK_DIR}/zentest.log")
        file_lines = file_content.split(/$/)
        start_line = 0
        next if file_lines[start_line].nil?
        html += "<tr class='#{ i % 2 == 0 ? 'a' : 'b'}'>"
        html += "<td><a href='xdoc/#{runner.gsub(/\//,'_')}.html' target='_blank'>#{runner}</a><br/><strong>run against</strong><br/><a href='xdoc/#{"test/unit/#{runner.split("/")[2].gsub(Regexp.new(".rb"),"_test.rb")}".gsub(/\//,'_')}.html' target='_blank'>test/unit/#{runner.split("/")[2].gsub(Regexp.new(".rb"),"_test.rb")}</a></td>"
        while file_lines[start_line].index("Code Generated by ZenTest").nil?
          start_line = start_line + 1
        end
        end_line = start_line
        while file_lines[end_line].index("Number of errors detected").nil?
          end_line = end_line + 1
        end
        number_of_errors = file_lines[end_line][29..(file_lines[end_line].length - 1)]
        end_line = end_line - 1
        html = html + "<td style='text-align: center;'><img src='images/icon_#{(number_of_errors.to_i == 0) ? 'success' : 'error'}_sml.gif'/></td>"
        html = html + "<td style='text-align: center;'>#{number_of_errors}</td>"
        html = html + "<td style='width: 75%;'><pre style='font-family: Courier New; font-size: 11px;'>"
        (start_line..end_line).to_a.each do |index|
          html = html + file_lines[index]
        end
        html = html + "</pre></td></tr>"
        i = i + 1
      end
    end
    html = html + "</tbody></table>"
  end
end

