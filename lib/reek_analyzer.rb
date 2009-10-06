require 'utils.rb'
require 'reek_builder.rb'
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
    #File.delete("reek.log")
  end

  # extracting HTML for reek
  def to_html
    File.open("#{Utils::WORK_DIR}/reek.html", "wb") do |file|
      file.write("<div id='bodyColumn'><div class='contentBox'>")
      file.write("<div class='section'><a name='reek'></a><h2>Reek Results for #{@file}</h2>")
      file.write("<p><a href='http://reek.rubyforge.org/' target='_blank'>Reek</a> detects common code smells in ruby code.</p>")
      #file.write(Utils.heading_for_builder("Common code smells freeness : #{"%0.2f" % ReekBuilder.percent}%", ReekBuilder.percent) %>
      file.write("<table class='bodyTable'><tr><th>Code Smell</th></tr>")
      @code_smells.each_with_index do |code_smell, index|
        file.write("<tr class='#{index % 2 == 0 ? 'a' : 'b'}'><td>#{code_smell}</td></tr>")
      end
      file.write("</table><p>Generated on #{Time.now.localtime}</p></div></div></div>")
    end
  end

  private

  # extracting content logic from flog log file
  def extract_content(str)
    @code_smells << str.strip if str.match(/^ /)
  end

end

