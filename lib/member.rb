# Membre d'un projet
# Author:: Vincent Dubois
# Date : 08 aout 2009 - version 0.0.5
class Member
  attr_accessor :id, :name, :email, :roles, :company

  # Constructeur par defaut
  def initialize
    @id = "defaultmemberid"
    @name = "Default member name"
    @email = "defaultemail@member"
    @roles = "default"
    @company = "Default company name"
  end
end

