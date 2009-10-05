require 'utils.rb'
# Analyseur de qualite de code Ruby
# Author:: Vincent Dubois
# Date : 05 octobre 2009 - version 0.0.5
class ReekAnalyzer
  attr_accessor :file, :code_smells

  # constructeur
  def initialize(file)
    @file = file
    @code_smells = []
  end

  # traitement sur fichier a analyser
  def perform
    Utils.run_command("reek #{@file} > reek.log")
    reek_extracted_lines = File.read("reek.log").split(/$/)
    reek_extracted_lines.each do |line|
      extract_content(line) unless line.strip.empty?
    end
    File.delete("reek.log")
  end

  private

  # extracting content logic from flog log file
  def extract_content(str)
    str_splitted = str.split(/  /)
    @code_smells << str_splitted[0]
  end
end

