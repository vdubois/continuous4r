require 'rubygems'
require 'cgi'

# Formatting unit tests class
# <b>Author</b>:: Vincent&#160;Dubois[mailto:duboisv@hotmail.com]
# <b>Date</b>:: 24/08/2009
class TestsFormatter
  attr_accessor :errors_or_warnings

  # Constructor
  def initialize
    @errors_or_warnings = 0
  end

  # Method which outputs the results of unit tests in HTML format
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

  # core tests run method
  # <b>runner</>:: tests type
  def core_test_run(runner)
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
    result ||= ""
    error_detail ||= ""
    return result, error_detail
  end

  # verifies if a test is OK or not
  # <b>result</b>:: output of test
  # <b>error_detail</b>:: error details of test
  def test_passed?(result, error_detail)
    result.index("Failure:").nil? and result.index("Error:").nil? and error_detail.match(/rake aborted/).nil?
  end

  # initializes HTML for a new line of test results
  # <b>runner</b>:: type of tests
  # <b>index</b>:: index of test
  # <b>passed</b>:: wether the test passed or not
  def generate_line_start(runner, index, passed)
    "<tr class='#{ index % 2 == 0 ? 'a' : 'b'}' style='#{passed == true ? "background-color: #e3ffdb; color: #7ab86c;" : "background-color: #ffdddd; color: #770000;"}'><td><strong>#{runner}</strong></td>"
  end

  # initializes HTML for 'passed' flag column
  # <b>passed</b>:: wether the test passed or not
  def generate_passed_column(passed)
    "<td style='text-align: center;'><img src='images/icon_#{passed ? 'success' : 'error'}_sml.gif'/></td>"
  end

  # initializes results for current test
  # <b>array_file_content</b>:: array content of log file
  def initialize_results(array_file_content)
    index_for_result = 0
    if Config::CONFIG['host_os'] =~ /mswin/
      index_for_result = 2
    else
      index_for_result = 1
    end
    test_results = array_file_content[array_file_content.length - index_for_result].sanitize_from_terminal_to_html.split(/, /).split(/, /)
    tests = test_results[0]
    assertions = test_results[1]
    failures = test_results[2]
    failures ||= 0
    errors = test_results[3]
    errors ||= 0
    return tests, assertions, failures
  end

  # error detection method
  # <b>error_detail</b>:: result detail of test
  def error_found(error_detail)
    !(error_detail.match(/rake aborted/).nil?) and error_detail.split(/$/).length > 1
  end

  # extract actual error from multiple error detail lines
  # <b>error_detail</b>:: multiple error detail lines
  def extract_actual_error_detail(error_detail)
    arr_error = error_detail.split(/$/)
    arr_error.delete_at(arr_error.length - 1)
    if Config::CONFIG['host_os'] =~ /mswin/
      arr_error.delete_at(arr_error.length - 1)
    end
    arr_error.delete_at(0)
    arr_error.to_s
  end

  # construction of details array from file content array
  # <b>array_file_content</b>:: file content array
  def construct_details_array(array_file_content)
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
  end

  # error caracteristics generation
  # <b>array_details</b>:: error details array
  # <b>arr_index</b>:: index of error
  def generate_error_caracteristics(array_details, arr_index)
    error_failure_type = array_details[arr_index][0].split(/\)/)[1].split(/:/)[0] unless array_details[arr_index][0].nil? or array_details[arr_index][0].split(/\)/)[1].nil?
    error_icon = (error_failure_type.match(/Error/) ? "<img src='images/exclamation.png'/>" : "<img src='images/error.png'/>")
    return error_failure_type, error_icon
  end

  # generate HTML for error detail line start
  # <b>error_failure_type</b>:: error type (error or failure)
  # <b>error_icon</b>:: error icon
  # <b>array_details</b>:: error details array
  # <b>arr_index</b>:: index of error
  def generate_line_detail_start(error_failure_type, error_icon, array_details, arr_index)
    "<tr style='#{error_failure_type.match(/Error/) ? "background-color: #ffdddd; color: #770000;" : "background-color: #fffccf; color: #666600;"}'><td align='center'>#{error_icon}</td><td><strong>#{array_details[arr_index][1].split(/\(/)[1].split(/\)/)[0]}##{array_details[arr_index][1].split(/\(/)[0]}</strong>"
  end

  # generate HTML for error detail line start
  # <b>array_details</b>:: error details array
  # <b>arr_index</b>:: index of error
  def generate_line_detail_end(array_details, arr_index)
    "<br/><pre>#{CGI::escapeHTML(array_details[arr_index].to_s)}</pre></td></tr>"
  end

  # executing tests method
  # <b>runner</b>:: tests type
  # <b>index</b>::  running tests index
  def run_runner(runner, index)
    html = ""
    project = Continuous4r.project
    puts " Running #{runner} tests..."
    passed = false
    result, error_detail = core_test_run(runner)
    passed = test_passed?(result, error_detail)
    if error_found(error_detail)
      error_detail = extract_actual_error_detail(error_detail)
    end
    html += generate_line_start(runner, index, passed)
    raise " #{runner} tests failed.\n BUILD FAILED." if project.ignore_test_failures == false and passed == false
    File.open("#{Continuous4r::WORK_DIR}/test_#{runner}.log", "w") do |file|
      file.write(result)
    end
    html += generate_passed_column(passed)
    array_file_content = File.read("#{Continuous4r::WORK_DIR}/test_#{runner}.log").split(/$/)
    tests, assertions, failures = initialize_results(array_file_content)
    @errors_or_warnings += failures.to_i
    @errors_or_warnings += errors.to_i
    if failures.to_i > 0 or errors.to_i > 0
      array_details = construct_details_array(array_file_content)
      (0..index).to_a.each do |arr_index|
        error_failure_type, error_icon = generate_error_caracteristics(array_details, arr_index)
        html_details += generate_line_detail_start(error_failure_type, error_icon, array_details, arr_index)
        array_details[arr_index].delete_at(1)
        array_details[arr_index].delete_at(0)
        html_details += generate_line_detail_end(array_details, arr_index)
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

