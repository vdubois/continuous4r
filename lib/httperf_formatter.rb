# ===================================================
# Classe de formatage de resultat renvoye par httperf
# Author: Vincent Dubois
# ===================================================
class HttperfFormatter
  attr_accessor :results, :description
  
  # Constructeur
  def initialize results, description
    self.results = results
    self.description = description
  end
  
  # Methode qui permet de fabriquer le flux HTML a partir du flux console httperf
  def to_html
    html = "<h3>Statistics for task '#{self.description}' :</h3><table class='bodyTable'><tbody>"
    begin
      results_lines = self.results.split(/$/)
      # On enleve la premiere ligne d'espace, sinon elle apparait en premier
      if results_lines.length > 2 #and results_lines[2] == ""
        results_lines.delete_at(2)
        results_lines.delete_at(results_lines.length-1)
      end
      i = 0
      results_lines.each do |line|
        if line[0..0].to_i == 0
          elements = line[1..line.length].split(/$|\:/)
        else
          elements = line.split(/$|\:/)
        end
	html = html + "<tr class='" + (i % 2 == 0 ? "a" : "b" ) + "'>" + format_line(elements) + "</tr>"
        i = i + 1
      end
    rescue Exception => e
      raise " Unable to format httperf results. Exception is : #{e.to_s}"
    end
    html = html + "</tbody></table>"
  end
  
  # Methode qui permet de formater une ligne de presentation des resultats
  def format_line elements
    line = ""
    if elements.length == 0
      line = line + "<td colspan='11'>&#160;</td>"
    else
      details = elements[1].split(' ') if elements.length > 1
      if elements[0] != "Maximum connect burst length" and elements[0][0..6] != "ttperf "
        line = line + "<td><b>#{elements[0]}</b></td>"
      end
      case elements[0]
      when "Total"
        line = line + "<td><b>#{details[0]}</b></td>"
        line = line + "<td>#{details[1]}</td>"
        line = line + "<td><b>#{details[2]}</b></td>"
        line = line + "<td>#{details[3]}</td>"
        line = line + "<td><b>#{details[4]}</b></td>"
        line = line + "<td>#{details[5]}</td>"
        line = line + "<td><b>#{details[6]}</b></td>"
        line = line + "<td colspan='3'>#{details[7]} #{details[8]}</td>"
      when "Connection rate"
        line = line + "<td colspan='10'>#{elements[1]}</td>"
      when "Connection time [ms]"
        line = line + "<td><b>#{details[0]}</b></td>"
        if details[0] == "min"
          line = line + "<td>#{details[1]}</td>" 
          line = line + "<td><b>#{details[2]}</b></td>"
          line = line + "<td>#{details[3]}</td>" 
          line = line + "<td><b>#{details[4]}</b></td>"
          line = line + "<td>#{details[5]}</td>" 
          line = line + "<td><b>#{details[6]}</b></td>"
          line = line + "<td>#{details[7]}</td>" 
          line = line + "<td><b>#{details[8]}</b></td>"
          line = line + "<td>#{details[9]}</td>"
        else
          line = line + "<td colspan='9'>#{details[1]}</td>" 
        end
      when "Connection length [replies/conn]"
        line = line + "<td colspan='10'>#{elements[1]}</td>"
      when "Request rate"
        line = line + "<td colspan='10'>#{elements[1]}</td>"
      when "Request size [B]"
        line = line + "<td colspan='10'>#{elements[1]}</td>"
      when "Reply rate [replies/s]"
        line = line + "<td><b>#{details[0]}</b></td>"
        line = line + "<td>#{details[1]}</td>" 
        line = line + "<td><b>#{details[2]}</b></td>"
        line = line + "<td>#{details[3]}</td>" 
        line = line + "<td><b>#{details[4]}</b></td>"
        line = line + "<td>#{details[5]}</td>" 
        line = line + "<td><b>#{details[6]}</b></td>"
        line = line + "<td>#{details[7]}</td>" 
        line = line + "<td colspan='3'><i>#{details[8]} #{details[9]}</i></td>"
      when "Reply time [ms]"
        line = line + "<td><b>#{details[0]}</b></td>"
        line = line + "<td>#{details[1]}</td>" 
        line = line + "<td><b>#{details[2]}</b></td>"
        line = line + "<td colspan='8'>#{details[3]}</td>"
      when "Reply size [B]"
        line = line + "<td><b>#{details[0]}</b></td>"
        line = line + "<td>#{details[1]}</td>" 
        line = line + "<td><b>#{details[2]}</b></td>"
        line = line + "<td>#{details[3]}</td>" 
        line = line + "<td><b>#{details[4]}</b></td>"
        line = line + "<td>#{details[5]}</td>" 
        line = line + "<td colspan='5'><i>#{details[6]} #{details[7]}</i></td>"
      when "Reply status"
        line = line + "<td>#{details[0]}</td>" 
        line = line + "<td>#{details[1]}</td>" 
        line = line + "<td>#{details[2]}</td>" 
        line = line + "<td>#{details[3]}</td>" 
        line = line + "<td colspan='7'>#{details[4]}</td>"
      when "CPU time [s]"
        line = line + "<td><b>#{details[0]}</b></td>"
        line = line + "<td>#{details[1]}</td>" 
        line = line + "<td><b>#{details[2]}</b></td>"
        line = line + "<td>#{details[3]}</td>" 
        line = line + "<td colspan='7'><i>#{details[4]} #{details[5]} #{details[6]} #{details[7]} #{details[8]} #{details[9]}</i></td>"
      when "Net I/O"
        line = line + "<td colspan='10'>#{elements[1]}</td>"
      when "Errors"
        line = line + "<td><b>#{details[0]}</b></td>"
        line = line + "<td>#{details[1]}</td>" 
        line = line + "<td><b>#{details[2]}</b></td>"
        line = line + "<td>#{details[3]}</td>" 
        line = line + "<td><b>#{details[4]}</b></td>"
        line = line + "<td>#{details[5]}</td>" 
        line = line + "<td><b>#{details[6]}</b></td>"
        if details[0] == "total"
          line = line + "<td>#{details[7]}</td>" 
          line = line + "<td><b>#{details[8]}</b></td>"
          line = line + "<td>#{details[9]}</td>"
        else
          line = line + "<td colspan='4'>#{details[7]}</td>" 
        end
      when "Session rate [sess/s]"
        line = line + "<td><b>#{details[0]}</b></td>"
        line = line + "<td>#{details[1]}</td>" 
        line = line + "<td><b>#{details[2]}</b></td>"
        line = line + "<td>#{details[3]}</td>" 
        line = line + "<td><b>#{details[4]}</b></td>"
        line = line + "<td>#{details[5]}</td>" 
        line = line + "<td><b>#{details[6]}</b></td>"
        line = line + "<td>#{details[7]}</td>" 
        line = line + "<td colspan='3'><i>#{details[8]}</i></td>"
      when "Session"
        line = line + "<td><b>#{details[0]}</b></td>"
        line = line + "<td colspan='9'>#{details[1]} #{details[2]}</td>"
      when "Session lifetime [s]"
        line = line + "<td colspan='10'>#{elements[1]}</td>"
      when "Session failtime [s]"
        line = line + "<td colspan='10'>#{elements[1]}</td>"
      when "Session length histogram"
        line = line + "<td colspan='10'>#{elements[1]}</td>"
      end
      return line
    end
  end
  
  private :format_line
end
