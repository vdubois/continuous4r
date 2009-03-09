require 'rubygems'
require 'XmlElements'
# =====================================================
# Classe de formatage des resultats renvoyes par les
# differents tests unitaires
# Author: Vincent Dubois
# =====================================================
class TestsFormatter
  # Methode qui permet de fabriquer le flux HTML a partir des flux console
  # de tests unitaires
  def to_html
    html = "<table class='bodyTable'><thead><th>Testing element</th><th>Pass</th><th>Tests</th><th>Result</th><th>Time</th></thead><tbody>"
    i = 0
    project = XmlElements.fromString(File.read("continuous4r-project.xml"))
    errors_or_warnings = 0
    html_details = ""
    ['units', 'functionals', 'integration'].each do |runner|
      puts " Running #{runner} tests..."
      result = Utils.run_command("rake test:#{runner}")
      passed = (result.index("Failure:").nil? and result.index("Error:").nil? and result.index("pending migrations").nil? and result.split(/$/).length > 1)
      html += "<tr class='#{ i % 2 == 0 ? 'a' : 'b'}' style='#{passed == true ? "background-color: #e3ffdb; color: #7ab86c;" : "background-color: #ffdddd; color: #770000;"}'><td><strong>#{runner}</strong></td>"
      if project['ignore-tests-failures'] == "false" and passed == false
        raise " #{runner} tests failed.\n BUILD FAILED."
      end
      f = File.open("#{Continuous4r::WORK_DIR}/test_#{runner}.log", "w")
      f.write(result)
      f.close
      html += "<td style='text-align: center;'><img src='images/icon_#{passed ? 'success' : 'error'}_sml.gif'/></td>"
      file_content = File.read("#{Continuous4r::WORK_DIR}/test_#{runner}.log")
      array_file_content = file_content.split(/$/)
      test_results = array_file_content[array_file_content.length - 2].split(/, /)
      tests = test_results[0]
      assertions = test_results[1]
      failures = test_results[2]
      failures ||= 0
      errors_or_warnings += failures.to_i
      errors = test_results[3]
      errors ||= 0
      errors_or_warnings += errors.to_i
      if failures.to_i > 0 or errors.to_i > 0
        array_details = Array.new
        array_get = false
        index = 0
        array_file_content.each do |line|
          array_get = !array_get if line.length == 1
          if array_get and line.match(/assertions/).nil?
            array_details[index] = Array.new if array_details[index].nil?
            next if array_details[index].length == 0 and line.match(/^ /).nil?
            array_details[index] << line
          end
          index += 1 if array_get and line.length == 0
        end
        #puts "#{index} : #{array_details[index][0]}"
        error_failure_type = array_details[index][0].split(/\)/)[1].split(/:/)[0]
        error_icon = (error_failure_type.match(/Error/) ? "<img src='images/exclamation.png'/>" : "<img src='images/error.png'/>")
        html_details += "<tr style='#{error_failure_type.match(/Error/) ? "background-color: #ffdddd; color: #770000;" : "background-color: #fffccf; color: #666600;"}'><td align='center'>#{error_icon}</td><td>#{array_details[index][1].split(/\(/)[1].split(/\)/)[0]}##{array_details[index][1].split(/\(/)[0]}</td>"
        array_details[index].delete_at(1)
        array_details[index].delete_at(0)
        html_details += "<td><pre>#{array_details[index]}</pre></td></tr>"
      end
      if array_file_content.select{|l| l =~ /^Finished in/}.length == 0
        html += "<td>0</td><td>&#160;</td><td>0 seconds</td></tr>"
      else
        html += "<td>#{tests.split(/ tests/)[0]}</td><td><img src='images/accept.png' align='absmiddle'/>&#160;#{assertions}&#160;&#160;<img src='images/error.png' align='absmiddle'/>&#160;#{failures}&#160;&#160;<img src='images/exclamation.png' align='absmiddle'/>&#160;#{errors}</td>"
        html += "<td>#{array_file_content.select{|l| l =~ /^Finished in/}[0].split(/Finished in /)[1].split(/\.$/)[0]}</td></tr>"
      end
      i += 1
    end
    html += "</tbody></table>"
    return html if errors_or_warnings == 0
    html += "<h3>Errors/Failures details</h3><table class='bodyTable'><thead><th>Type</th><th>Method</th><th>Trace</th></thead>#{html_details}</table>"
  end
end
