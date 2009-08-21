# Societe dont depend un projet
# Author:: Vincent Dubois
# Date : 08 aout 2009 - version 0.0.5
class Company
  attr_accessor :name, :denomination, :url, :logo

  # Constructeur par defaut
  def initialize
    @name = "Default company"
    @denomination = "Default company denomination"
    @url = "http://defaultcompanyurl"
    @logo = "http://defaultcompanyurl/logo.png"
  end
end

