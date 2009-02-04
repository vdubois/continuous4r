# ================================================
# Classe de formatage de resultat renvoye par flog
# Author: Vincent Dubois
# ================================================
class FlogFormatter
  attr_accessor :results
  
  # Constructeur
  def initialize results
    self.results = results
  end
  
  # Methode qui permet de fabriquer le flux HTML a partir du flux console flog
  def to_html
    lines = self.results.split(/$/)
    total_score = lines[0].split(" = ")[1]
    html = "<h3>Total score : #{total_score}</h3>"
    # On supprime les deux premieres lignes (total et ligne vide) et la derniere (ligne vide)
    lines.delete_at(0)
    lines.delete_at(0)
    lines.delete_at(lines.length-1)
    begin
      lines.each_with_index do |line, index|
        html = html + format_line(line, index)
      end
    rescue Exception => e
      raise " Unable to format flog results. Exception is : #{e.to_s}"
    end
    html = html + "</tbody></table>"
  end
  
  # Méthode qui permet de formater une ligne de resultat
  def format_line line, index
    html = ""
    if line[1..1] != ' '
      if index != 0
        html = html + "</tbody></table><br/>"
      end
      html = html + "<table class='bodyTable'><thead><th>Element</th><th>Score</th></thead><tbody>"
      total_score = line.split(': ')[1]
      total_score = total_score.split(/\(|\)/)
      html = html + "<tr class='#{index % 2 == 0 ? "a" : "b"}'><td><b>#{line.split(': ')[0]}</b></td><td><b>#{total_score}</b></td></tr>"
    else
      html = html + "<tr class='#{index % 2 == 0 ? "a" : "b"}'><td>&#160;&#160;&#160;&#160;&#160;#{line.split(': ')[1]}</td><td>#{line.split(': ')[0]}</td></tr>"
    end
    return html
  end
end
