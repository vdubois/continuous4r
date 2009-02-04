require 'rubygems'
require 'XmlElements'
# =====================================================
# Classe de formatage des resultats renvoyes par heckle
# Author: Vincent Dubois
# =====================================================
class HeckleFormatter
  attr_accessor :params
  
  # Constructeur
  def initialize params
    self.params = params
  end
  
  # Methode qui permet de fabriquer le flux HTML a partir des flux console heckle
  def to_html
    html = "<table class='bodyTable'><thead><th>Testing element</th><th>Pass</th><th>Result</th></thead><tbody>"
    i = 0
    self.params.each('test') do |test|
      puts " Running heckle on #{test['class']} against #{test['test_pattern']}..."
      pass = system("heckle #{test['class']} -t #{test['test_pattern']} > heckle.log")
      html = html + "<tr class='#{ i % 2 == 0 ? 'a' : 'b'}'><td><strong>#{test['class']}</strong> against <strong>#{test['test_pattern']}</strong></td><td style='text-align: center;'><img src='images/icon_#{pass ? 'success' : 'error'}_sml.gif'/></td><td><pre>#{File.read("heckle.log")}</pre></td></tr>"
      i = i + 1
    end
    html = html + "</tbody></table>"
  end
end
