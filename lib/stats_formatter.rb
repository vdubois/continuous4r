# =========================================================
# Classe de formatage des resultats renvoyes par rake stats
# Author: Vincent Dubois
# =========================================================
class StatsFormatter
  attr_accessor :result
  attr_reader :percent

  # Constructeur
  def initialize result
    self.result = result
  end
  
  # Methode qui permet de fabriquer le flux HTML a partir des flux console
  def to_html
    html = "<table class='bodyTable'><thead><th>Name</th><th>Lines</th><th>LOC</th><th>Classes</th><th>Methods</th><th>M/C</th><th>LOC/M</th></thead><tbody>"
    i = 0
    results = self.result.split(/$/)
    bottom = 4
    while !results[bottom].nil? and results[bottom][0..1] != "\n+" do
      bottom = bottom + 1
    end
    lines = results[4..bottom-1]
    lines.each do |line|
      elements = line.split(/\|/)
      html = html + "<tr class='#{ i % 2 == 0 ? 'a' : 'b'}'>"
      html = html + "<td><strong>#{elements[1]}</strong></td>"
      html = html + "<td style='text-align: right;'>#{elements[2]}</td>"
      html = html + "<td style='text-align: right;'>#{elements[3]}</td>"
      html = html + "<td style='text-align: right;'>#{elements[4]}</td>"
      html = html + "<td style='text-align: right;'>#{elements[5]}</td>"
      html = html + "<td style='text-align: right;'>#{elements[6]}</td>"
      html = html + "<td style='text-align: right;'>#{elements[7]}</td>"
      html = html + "</tr>"
      i = i + 1
    end
    total = results[bottom + 1]
    elements = total.split(/\|/)
    html = html + "<tr class='#{ i % 2 == 0 ? 'a' : 'b'}'>"
    html = html + "<td><strong>#{elements[1]}</strong></td>"
    [2,3,4,5,6,7].each do |j|
      html = html + "<td style='text-align: right;'><strong>#{elements[j]}</strong></td>"
    end
    html = html + "</tr>"
    html = html + "</tbody></table>"
    extra = results[bottom + 3]
    elements = extra.split(/:|    /)
    @percent = (elements[3].strip.to_f * 100.0) / elements[1].strip.to_f
    html = html + "<p><strong>#{elements[0]} : </strong>#{elements[1]}&#160;&#160;&#160;&#160;&#160;&#160;"
    html = html + "<strong>#{elements[2]} : </strong>#{elements[3]}&#160;&#160;&#160;&#160;&#160;&#160;"
    html = html + "<strong>#{elements[4]} : </strong>#{elements[5]}:#{elements[6]}</p><br/>"
  end
end
