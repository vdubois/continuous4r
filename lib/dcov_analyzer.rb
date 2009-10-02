require 'utils.rb'
# Analyseur de documentation de fichier Ruby
# Author:: Vincent Dubois
# Date : 02 octobre 2009 - version 0.0.5
class DcovAnalyzer
  attr_accessor :file

  # constructeur
  def initialize(file)
    @file = file
  end

  # traitement sur fichier a analyser
  def perform
    log = Utils.run_command("dcov #{@file}")
  end
end

