require 'rubygems'
require 'cgi'
# =====================================================
# Classe de formatage des resultats renvoyes par les
# differents tests unitaires
# Author: Vincent Dubois
# =====================================================
class TestsFormatter
  # Methode qui permet de fabriquer le flux HTML a partir des flux console
  # de tests unitaires
  attr_accessor :errors_or_warnings

  def initialize
    @errors_or_warnings = 0
  end

  def to_html
    html = "<table class='bodyTable'><thead><th>Testing element</th><th>Pass</th><th>Tests</th><th>Result</th><th>Time</th></thead><tbody>"
    i = 0
    html_details = ""
    if !(Config::CONFIG['host_os'] =~ /mswin/)
      require 'open3'
    end
    ['units', 'functionals', 'integration'].each_with_index do |runner,index|
      html += run_runner(runner, index)
    end
    html += "</tbody></table>"
    return html if @errors_or_warnings == 0
    html += "<h3>Errors/Failures details</h3><table class='bodyTable'><thead><th>Type</th><th>Method/Trace</th></thead>#{html_details}</table>"
  end

  def run_runner(runner, index)
    html = ""
    project = Continuous4r.project
    puts " Running #{runner} tests..."
    error_detail = ""
    result = ""
    passed = false
    if Config::CONFIG['host_os'] =~ /mswin/
      stdout = IO.popen("cmd.exe /C rake test:#{runner} 2>test_#{runner}_error.log")
      result = stdout.read
      error_detail = File.read("test_#{runner}_error.log")
    else
      Open3::popen3("rake test:#{runner}") do |stdin, stdout, stderr, pid|
        result = stdout.read.strip
        if result.match(/Finished in/).nil?
          error_detail = stderr.read.strip
        end
      end
    end
    passed = (result.index("Failure:").nil? and result.index("Error:").nil? and error_detail.match(/rake aborted/).nil?)
    if !(error_detail.match(/rake aborted/).nil?) and error_detail.split(/$/).length > 1
      arr_error = error_detail.split(/$/)
      arr_error.delete_at(arr_error.length - 1)
      if Config::CONFIG['host_os'] =~ /mswin/
	  arr_error.delete_at(arr_error.length - 1)
	end
      arr_error.delete_at(0)
      error_detail = arr_error.to_s
    end
    html += "<tr class='#{ index % 2 == 0 ? 'a' : 'b'}' style='#{passed == true ? "background-color: #e3ffdb; color: #7ab86c;" : "background-color: #ffdddd; color: #770000;"}'><td><strong>#{runner}</strong></td>"
    if project.ignore_test_failures == false and passed == false
      raise " #{runner} tests failed.\n BUILD FAILED."
    end
    f = File.open("#{Continuous4r::WORK_DIR}/test_#{runner}.log", "w")
    f.write(result)
    f.close
    html += "<td style='text-align: center;'><img src='images/icon_#{passed ? 'success' : 'error'}_sml.gif'/></td>"
    file_content = File.read("#{Continuous4r::WORK_DIR}/test_#{runner}.log")
    array_file_content = file_content.split(/$/)
    if Config::CONFIG['host_os'] =~ /mswin/
      test_results = array_file_content[array_file_content.length - 2].sanitize_from_terminal_to_html.split(/, /).split(/, /)
    else
      test_results = array_file_content[array_file_content.length - 1].sanitize_from_terminal_to_html.split(/, /).split(/, /)
    end
    tests = test_results[0]
    assertions = test_results[1]
    failures = test_results[2]
    failures ||= 0
    @errors_or_warnings += failures.to_i
    errors = test_results[3]
    errors ||= 0
    @errors_or_warnings += errors.to_i
    if failures.to_i > 0 or errors.to_i > 0
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
        error_failure_type = array_details[arr_index][0].split(/\)/)[1].split(/:/)[0] unless array_details[arr_index][0].nil? or array_details[arr_index][0].split(/\)/)[1].nil?
        error_icon = (error_failure_type.match(/Error/) ? "<img src='images/exclamation.png'/>" : "<img src='images/error.png'/>")
        html_details += "<tr style='#{error_failure_type.match(/Error/) ? "background-color: #ffdddd; color: #770000;" : "background-color: #fffccf; color: #666600;"}'><td align='center'>#{error_icon}</td><td><strong>#{array_details[arr_index][1].split(/\(/)[1].split(/\)/)[0]}##{array_details[arr_index][1].split(/\(/)[0]}</strong>"
        array_details[arr_index].delete_at(1)
        array_details[arr_index].delete_at(0)
        html_details += "<br/><pre>#{CGI::escapeHTML(array_details[arr_index].to_s)}</pre></td></tr>"
      end
    end
    if array_file_content.select{|l| l =~ /^Finished in/}.length == 0
      html += "<td>0</td><td><pre>#{error_detail if !passed}</pre></td><td>0 seconds</td></tr>"
    else
      html += "<td>#{tests.split(/ tests/)[0]}</td><td><img src='images/accept.png' align='absmiddle'/>&#160;#{assertions}&#160;&#160;<img src='images/error.png' align='absmiddle'/>&#160;#{failures}&#160;&#160;<img src='images/exclamation.png' align='absmiddle'/>&#160;#{errors}</td>"
      html += "<td>#{array_file_content.select{|l| l =~ /^Finished in/}[0].split(/Finished in /)[1].split(/\.$/)[0]}</td></tr>"
    end
  end
end

