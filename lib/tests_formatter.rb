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
    html = "<table class='bodyTable'><thead><th>Testing element</th><th>Pass</th><th>Result</th></thead><tbody>"
    i = 0
    project = XmlElements.fromString(File.read("continuous4r-project.xml"))
    ['units','functionals','integration'].each do |runner|
      puts " Running #{runner} tests..."
      html = html + "<tr class='#{ i % 2 == 0 ? 'a' : 'b'}'><td><strong>#{runner}</strong></td>"
      result = Utils.run_command("rake test:#{runner}")
      passed = (result.index("Failure:").nil? and result.index("Error:").nil? and result.index("pending migrations").nil? and result.split(/$/).length > 1)
      if project['ignore-tests-failures'] == "false" and passed == false
        raise " #{runner} tests failed.\n BUILD FAILED."
      end
      f = File.open("#{Continuous4r::WORK_DIR}/test_#{runner}.log", "w")
      f.write(result)
      f.close
      html = html + "<td style='text-align: center;'><img src='images/icon_#{passed ? 'success' : 'error'}_sml.gif'/></td>"
      html = html + "<td><pre>#{File.read("#{Continuous4r::WORK_DIR}/test_#{runner}.log")}</pre></td></tr>"
      i = i + 1
    end
    html = html + "</tbody></table>"
  end
end
