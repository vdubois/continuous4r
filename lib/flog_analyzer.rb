require 'utils.rb'
# Analyseur de qualite de code Ruby
# Author:: Vincent Dubois
# Date : 02 octobre 2009 - version 0.0.5
class FlogAnalyzer
  attr_accessor :file

  # constructeur
  def initialize(file)
    @file = file
    @average = 0
    @total = 0
  end

  # traitement sur fichier a analyser
  def perform
    File.open("flog.log", "wb+") do |file|
      file.write("@file\n")
    end
    Utils.run_command("flog #{@file} >> flog.log")
  end

  def 
end

