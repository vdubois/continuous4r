require 'utils.rb'
# Analyseur de qualite de code Ruby
# Author:: Vincent Dubois
# Date : 02 octobre 2009 - version 0.0.5
class FlogAnalyzer
  attr_accessor :file

  # constructeur
  def initialize(file)
    @file = file
  end

  # traitement sur fichier a analyser
  def perform
    log = Utils.run_command("flog #{@file} > flog.log")
  end
end

