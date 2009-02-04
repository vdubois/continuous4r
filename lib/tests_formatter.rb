require 'rubygems'
require 'XmlElements'
# =====================================================
# Classe de formatage des resultats renvoyes par les
# differents tests unitaires
# Author: Vincent Dubois
# =====================================================
class TestsFormatter
  attr_accessor :params
  
  # Constructeur
  def initialize params
    self.params = params
  end
  
  # Methode qui permet de fabriquer le flux HTML a partir des flux console
  # de tests unitaires
  def to_html
    html = "<table class='bodyTable'><thead><th>Testing element</th><th>Pass</th><th>Result</th></thead><tbody>"
    i = 0
    self.params.each('runner') do |runner|
      puts " Running #{runner['type']} tests..."
      pass = true
      html = html + "<tr class='#{ i % 2 == 0 ? 'a' : 'b'}'><td><strong>#{runner['type']}</strong></td>"
      case runner['type']
      when "units"
        pass = system("rake test:units > test_units.log")
        if !pass
          puts " #{File.read("test_units.log")}"
          raise " BUILD FAILED."
        end
        html = html + "<td style='text-align: center;'><img src='images/icon_#{pass ? 'success' : 'error'}_sml.gif'/></td>"
        html = html + "<td><pre>#{File.read("test_units.log")}</pre></td></tr>"
      when "functionals"
        pass = system("rake test:functionals > test_functionals.log")
        if !pass
          puts " #{File.read("test_functionals.log")}"
          raise " BUILD FAILED."
        end
        html = html + "<td style='text-align: center;'><img src='images/icon_#{pass ? 'success' : 'error'}_sml.gif'/></td>"
        html = html + "<td><pre>#{File.read("test_functionals.log")}</pre></td></tr>"
      when "integration"
        pass = system("rake test:integration > test_integration.log")
        if !pass
          puts " #{File.read("test_integration.log")}"
          raise " BUILD FAILED."
        end
        html = html + "<td style='text-align: center;'><img src='images/icon_#{pass ? 'success' : 'error'}_sml.gif'/></td>"
        html = html + "<td><pre>#{File.read("test_integration.log")}</pre></td></tr>"
      when "rspec"
        pass = system("rake spec > test_rspec.log")
        if !pass
          puts " #{File.read("test_rspec.log")}"
          raise " BUILD FAILED."
        end
        html = html + "<td style='text-align: center;'><img src='images/icon_#{pass ? 'success' : 'error'}_sml.gif'/></td>"
        html = html + "<td><pre>#{File.read("test_rspec.log").gsub(/\[32m|\[0m|\[31m/,"")}</pre></td></tr>"
      else
        raise " Don't know how to run '#{runner['type']}' test.\n BUILD FAILED."
      end
      i = i + 1
    end
    html = html + "</tbody></table>"
  end
end
