# ====================================================
# Classe de formatage des logs en sortie de Capistrano
# Author: Vincent Dubois
# ====================================================
class CapistranoFormatter
  attr_accessor :name, :log
  
  # Constructeur
  def initialize name, log
    self.name = name
    self.log = log
  end
  
  # Methode qui permet de fabriquer le flux HTML a partir des flux console heckle
  def to_html
    html = "<h3>cap #{self.name}</h3>"
    html = html + "<p><pre class='source'>#{self.log}</pre></p>"
  end
end
