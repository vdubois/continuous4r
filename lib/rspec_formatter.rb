require 'rubygems'
require 'XmlElements'
require 'cgi'
# =====================================================
# Classe de formatage des resultats renvoyes par les
# tests unitaires Rspec
# Author: Vincent Dubois
# Date: 11 mars 2009
# =====================================================
class RspecFormatter
  # Methode qui permet de fabriquer le flux HTML a partir des flux console
  # de tests unitaires
  def to_html
    html = "<table class='bodyTable'><thead><th>Testing element</th><th>Pass</th><th>Result</th><th>Time</th></thead><tbody>"
    i = 0
    project = XmlElements.fromString(File.read("continuous4r-project.xml"))
    errors_or_warnings = 0
    html_details = ""
    if !(Config::CONFIG['host_os'] =~ /mswin/)
      require 'open3'
    end
    ['spec'].each do |runner|
      puts " Running #{runner} tests..."
      error_detail = ""
      result = ""
      passed = false
      if Config::CONFIG['host_os'] =~ /mswin/
        stdout = IO.popen("cmd.exe /C rake #{runner} 2>test_#{runner}_error.log")
        result = stdout.read
        error_detail = File.read("test_#{runner}_error.log")
      else
        Open3::popen3("rake #{runner}") do |stdin, stdout, stderr, pid|
          result = stdout.read.strip
          if result.match(/Finished in/).nil?
            error_detail = stderr.read.strip
          end
        end
      end
      passed = (result.match(/1\)/).nil? and error_detail.match(/rake aborted/).nil? and !(result.match(/Finished in/).nil?))
      if !(error_detail.match(/rake aborted/).nil?) and error_detail.split(/$/).length > 1
        arr_error = error_detail.split(/$/)
        arr_error.delete_at(arr_error.length - 1)
        if Config::CONFIG['host_os'] =~ /mswin/
          arr_error.delete_at(arr_error.length - 1)
        end
        arr_error.delete_at(0)
        error_detail = arr_error.to_s
      end
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
      if Config::CONFIG['host_os'] =~ /mswin/
        array_sanitize = array_file_content[array_file_content.length - 2].gsub(/\[31m/, "").gsub(/\[32m/, "").gsub(/\[0m/, "")
        array_sanitize.slice!(0..1)
        array_sanitize.slice!((array_sanitize.length - 1)..(array_sanitize.length))
        test_results = array_sanitize.split(/, /)
      else
        array_sanitize = array_file_content[array_file_content.length - 1].gsub(/\[31m/, "").gsub(/\[32m/, "").gsub(/\[35m/, "").gsub(/\[0m/, "")
        array_sanitize.slice!(0..1)
        array_sanitize.slice!((array_sanitize.length - 1)..(array_sanitize.length))
        test_results = array_sanitize.split(/, /)
      end
      examples = test_results[0]
      failures = test_results[1]
      failures ||= 0
      errors_or_warnings += failures.to_i
      if failures.to_i > 0
        array_details = Array.new
        array_get = false
        index = 0
        array_file_content.each do |line|
          index += 1 if array_get and line.match(Regexp.new("#{index + 2}\\)"))
          array_get = true if line.match(Regexp.new("#{index + 1}\\)"))
          if array_get and line.match(/assertions/).nil?
            array_details[index] = Array.new if array_details[index].nil?
            next if array_details[index].length == 0 and line.match(/[0-9]\)/).nil?
            array_details[index] << line
          end
        end
        (0..index).to_a.each do |arr_index|
          error_icon = "<img src='images/exclamation.png'/>"
          html_details += "<tr style='background-color: #ffdddd; color: #770000;'><td align='center'>#{error_icon}</td><td>" #<strong>#{array_details[arr_index][1].split(/\(/)[1].split(/\)/)[0]}##{array_details[arr_index][1].split(/\(/)[0]}</strong>"
          array_details[arr_index].delete_at(0)
          if arr_index == index
            array_details[arr_index].delete_at(array_details[arr_index].length - 1)
            array_details[arr_index].delete_at(array_details[arr_index].length - 1)
            array_details[arr_index].delete_at(array_details[arr_index].length - 1)
            array_details[arr_index].delete_at(array_details[arr_index].length - 1)
          end
          file_path = array_details[arr_index][array_details[arr_index].length - 2]
          file_path.slice!((file_path.length - 1)..(file_path.length))
          failure_file_details = file_path.split(/:/)
          unless file_path.match(/\.\/spec\//).nil?
            failure_file_details[0].slice!(0..2)
            file_link = "<strong><a href='xdoclet/#{failure_file_details[0].gsub(/\//, "_").gsub(/\.rb/, ".rb.html")}' target='_blank'>#{file_path}</a></strong><br/>"
            array_details[arr_index].delete_at(array_details[arr_index].length - 2)
          else
            file_link = ""
          end
          html_details += "#{file_link}<pre>#{CGI::escapeHTML(array_details[arr_index].to_s.gsub(/\[31m/, "").gsub(/\[32m/, "").gsub(/\[0m/, "").gsub(/\[35m/, "").gsub(//, ""))}</pre></td></tr>"
        end
      end
      if array_file_content.select{|l| l =~ /^Finished in/}.length == 0
        html += "<td><pre>#{result.concat("\n").concat(error_detail) if !passed}</pre></td><td>0 seconds</td></tr>"
      else
        html += "<td><img src='images/accept.png' align='absmiddle'/>&#160;#{examples}&#160;&#160;<img src='images/exclamation.png' align='absmiddle'/>&#160;#{failures}</td>"
        html += "<td>#{array_file_content.select{|l| l =~ /^Finished in/}[0].split(/Finished in /)[1].split(/\.$/)[0]}</td></tr>"
      end
      i += 1
    end
    html += "</tbody></table>"
    return html if errors_or_warnings == 0
    html += "<h3>Errors/Failures details</h3><table class='bodyTable'><thead><th>Type</th><th>Trace</th></thead>#{html_details}</table>"
  end
end
