require 'rubygems'
require 'cgi'
# =====================================================
# Classe de formatage des resultats renvoyes par les
# tests unitaires Rspec
# Author: Vincent Dubois
# Date: 11 mars 2009
# =====================================================
class RspecFormatter

  # verifies if a test is OK or not
  # <b>result</b>:: output of test
  # <b>error_detail</b>:: error details of test
  def test_passed?(result, error_detail)
    (result.match(/1\)/).nil? and error_detail.match(/rake aborted/).nil? and !(result.match(/Finished in/).nil?))
  end

  # generates HTML header for test
  def generate_header
    "<table class='bodyTable'><thead><th>Testing element</th><th>Pass</th><th>Result</th><th>Time</th></thead><tbody>"
  end

  # run test runner
  # <b>runner</b>:: test runner type
  def run_runner(runner)
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
    return error_detail, result
  end

  # generate HTML for line start
  # <b>runner</b>:: runner type
  # <b>passed</b>:: test passed ?
  def generate_line_start(runner, passed)
    "<tr class='#{ i % 2 == 0 ? 'a' : 'b'}' style='#{passed == true ? "background-color: #e3ffdb; color: #7ab86c;" : "background-color: #ffdddd; color: #770000;"}'><td><strong>#{runner}</strong></td>"
  end

  # extracts test results from file content array
  # <b>array_file_content</b>:: file content array
  def extract_test_results(array_file_content)
    if Config::CONFIG['host_os'] =~ /mswin/
      array_sanitize = array_file_content[array_file_content.length - 2].sanitize_from_terminal_to_html
      array_sanitize.slice!(0..1)
      array_sanitize.slice!((array_sanitize.length - 1)..(array_sanitize.length))
      test_results = array_sanitize.split(/, /)
    else
      array_sanitize = array_file_content[array_file_content.length - 1].sanitize_from_terminal_to_html
      array_sanitize.slice!(0..1)
      array_sanitize.slice!((array_sanitize.length - 1)..(array_sanitize.length))
      test_results = array_sanitize.split(/, /)
    end
  end

  # generates error details HTML table
  # <b>html_details</b>:: the HTML error details string
  def generate_error_details(html_details)
    "<h3>Errors/Failures details</h3><table class='bodyTable'><thead><th>Type</th><th>Trace</th></thead>#{html_details}</table>"
  end

  # generates the default result time passed column
  # <b>result</b>:: test result
  # <b>error_detail</b>:: error detail of test
  # <b>passed</b>:: wether the test passed or not
  def generate_default_result_and_time_columns(result, error_detail, passed)
    "<td><pre>#{result.concat("\n").concat(error_detail) if !passed}</pre></td><td>0 seconds</td></tr>"
  end

  # generates the default result time passed column
  # <b>examples</b>:: number of rspec examples
  # <b>failures</b>:: number or rspec failures
  # <b>array_file_content</b>:: log file content array
  def generate_result_and_time_columns(examples, failures, array_file_content)
    "<td><img src='images/accept.png' align='absmiddle'/>&#160;#{examples}&#160;&#160;<img src='images/exclamation.png' align='absmiddle'/>&#160;#{failures}</td><td>#{array_file_content.select{|l| l =~ /^Finished in/}[0].split(/Finished in /)[1].split(/\.$/)[0]}</td></tr>"
  end

  # generates the HTML link from an error or failure
  # <b>failure_file_details</b>:: array of failure or error details
  # <b>file_path</b>:: error or failure file path
  def generate_link(failure_file_details, file_path)
    "<strong><a href='xdoclet/#{failure_file_details[0].gsub(/\//, "_").gsub(/\.rb/, ".rb.html")}' target='_blank'>#{file_path}</a></strong><br/>"
  end

  # generates a HTML line for an rspec error or failure
  # <b>array_details</b>:: details array of rspec test
  # <b>arr_index</b>:: index of error or failure
  def generate_failure_or_error_line(array_details, arr_index)
    html_details = "<tr style='background-color: #ffdddd; color: #770000;'><td align='center'><img src='images/exclamation.png'/></td><td>"
    array_details[arr_index].delete_at(0)
    if arr_index == index
      4.times do |index|
        array_details[arr_index].delete_at(array_details[arr_index].length - 1)
      end
    end
    file_path = array_details[arr_index][array_details[arr_index].length - 2]
    file_path.slice!((file_path.length - 1)..(file_path.length))
    failure_file_details = file_path.split(/:/)
    unless file_path.match(/\.\/spec\//).nil?
      failure_file_details[0].slice!(0..2)
      file_link = generate_link(failure_file_details, file_path)
      array_details[arr_index].delete_at(array_details[arr_index].length - 2)
    else
      file_link = ""
    end
    html_details << "#{file_link}<pre>#{CGI::escapeHTML(array_details[arr_index].to_s.sanitize_from_terminal_to_html)}</pre></td></tr>"
    return html_details, array_details
  end

  # Methode qui permet de fabriquer le flux HTML a partir des flux console
  # de tests unitaires
  def to_html
    html = generate_header
    i = 0
    project = Continuous4r.project
    errors_or_warnings = 0
    html_details = ""
    if !(Config::CONFIG['host_os'] =~ /mswin/)
      require 'open3'
    end
    ['spec'].each do |runner|
      error_detail, result = run_runner(runner)
      passed = test_passed?(result, error_detail)
      if !(error_detail.match(/rake aborted/).nil?) and error_detail.split(/$/).length > 1
        arr_error = error_detail.split(/$/)
        arr_error.delete_at(arr_error.length - 1)
        if Config::CONFIG['host_os'] =~ /mswin/
          arr_error.delete_at(arr_error.length - 1)
        end
        arr_error.delete_at(0)
        error_detail = arr_error.to_s
      end
      html << generate_line_start(runner, passed)
      if project.ignore_tests_failures == "false" and passed == false
        raise " #{runner} tests failed.\n BUILD FAILED."
      end
      f = File.open("#{Continuous4r::WORK_DIR}/test_#{runner}.log", "w")
      f.write(result)
      f.close
      html << "<td style='text-align: center;'><img src='images/icon_#{passed ? 'success' : 'error'}_sml.gif'/></td>"
      file_content = File.read("#{Continuous4r::WORK_DIR}/test_#{runner}.log")
      array_file_content = file_content.split(/$/)
      test_results = extract_test_results(array_file_content)
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
          myhtml_details, array_details = generate_failure_or_error_line(array_details, arr_index)
          html_details << myhtml_details
        end
      end
      if array_file_content.select{|l| l =~ /^Finished in/}.length == 0
        html << generate_default_result_and_time_columns(result, error_detail, passed)
      else
        html << generate_result_and_time_columns(examples, failures, array_file_content)
      end
      i += 1
    end
    html << "</tbody></table>"
    return html if errors_or_warnings == 0
    html << generate_error_details(html_details)
  end
end

