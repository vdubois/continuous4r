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
    @flogged_methods = []
  end

  # traitement sur fichier a analyser
  def perform
    Utils.run_command("flog #{@file} >> flog.log")
    flog_extracted_lines = File.read(@file).split(/$/)
    flog_extracted_lines.each do |line|
      extract_content(line)
    end
  end

  # getting average score
  def average_score
    @average
  end

  # getting total score
  def total_score
    @total
  end

  # getting flogged_methods
  def flogged_methods
    @flogged_methods
  end

  private
  
  # extracting content logic from flog log file 
  def extract_content(str)
    str_splitted = str.split(/: /)
    if str_splitted.include?("flog total")
      @total = str_splitted[0]
    else if str_splitted.include?("flog/method average")
      @average = str_splitted[0]
    else
      extract_method_content()
    end
  end
end

