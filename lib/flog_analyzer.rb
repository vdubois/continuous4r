require 'utils.rb'
# Analyseur de complexite de code Ruby
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
    flog_extracted_lines = File.read("flog.log").split(/$/)
    flog_extracted_lines.each do |line|
      extract_content(line) unless line.strip.empty?
    end
    File.delete("flog.log")
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
      @total = str_splitted[0].to_f
    elsif str_splitted.include?("flog/method average")
      @average = str_splitted[0].to_f
    else
      extract_method_content(str_splitted)
    end
  end

  # extracting content from method detail
  def extract_method_content(str_array)
    @flogged_methods << [str_array[1], str_array[0].strip.to_f]
  end
end

