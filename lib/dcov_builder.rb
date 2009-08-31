require 'rubygems'
require 'dcov'
require 'dcov_stats.rb'
# ==========================================================================
# Surcharge du module Dcov pour l'adapter aux besoins de continous4r
# author: Vincent Dubois
# date: 10 fevrier 2009
# ==========================================================================
module Dcov
  # Generates HTML output
  class Generator

    include Dcov::StatsRenderer::Helpers

    attr_reader :data
    def initialize(data)
      @data = data
    end

    def to_s
      build_stats_header + build_stats_body + build_stats_footer
    end

    def build_stats_header
      # Little CSS, a little HTML...
      output = "<h2>Dcov results</h2>\n\n<p><a href='http://dcov.rubyforge.org' target='_blank'>Dcov</a> is a documentation coverage analyzer for ruby.</p>"
    end

    # find some word in log and return its corresponding value
    # <b>word</b>:: word to find
    def find_in_rdoc_log(word)
      File.read("#{Continuous4r::WORK_DIR}/rdoc/rdoc.log").split(/$/).select { |l| l =~ Regexp.new("^#{word}:") }[0].strip.split(Regexp.new("#{word}:"))[1].strip.to_f
    end

    # builds HTML coverage summary
    # <b>global_coverage</b>:: global coverage for project
    # <b>class_coverage</b>:: classes coverage
    # <b>module_coverage</b>:: modules coverage
    # <b>method_coverage</b>:: methods coverage
    def build_summary(global_coverage, class_coverage, module_coverage, method_coverage)
      output = Utils.heading_for_builder("Global coverage percentage : #{global_coverage.to_i}%", global_coverage.to_i)
      output << "<h3>Summary</h3><p>\n<table class='bodyTable' style='width: 200px;'><tr><th>Type</th><th>Coverage</th></tr><tr class='a'><td><b>Class</b></td><td style='text-align: right;'>#{class_coverage}%</td></tr>\n<tr class='b'><td><b>Module</b></td><td style='text-align: right;'>#{module_coverage}%</td></tr>\n<tr class='a'><td><b>Method</b></td><td style='text-align: right;'>#{method_coverage}%</td></tr></table>\n</p>\n\n"
    end

    # builds a class error HTML column
    # <b>class_error_presence</b>:: if current error is a class error
    # <b>key</b>:: error key
    # <b>value</b>:: error data
    def build_class_error_column(class_error_presence, key, value)
      "<td>#{"<b>" if class_error_presence == true}#{key.is_a?(String) ? key : key.full_name }#{"</b> in <a href='xdoclet/#{value[0].in_files.first.file_absolute_name.gsub(/\//,'_')}.html' target='_blank'>#{value[0].in_files.first.file_absolute_name}</a>" if class_error_presence == true}</td>"
    end

    # builds a method error HTML column
    # <b>itm</b>:: method error item
    def build_method_error_column(itm)
      ((itm.comment.nil? || itm.comment == '') ? "<td><ol><li><b>#{itm.name}</b> in <a href='xdoclet/#{itm.token_stream.first.text.sub(/^# File /, '').sub(/, line (\d+)$/, '').gsub(/\//,'_')}.html##{itm.token_stream.first.text.sub(/^# File /, '').sub(/, line (\d+)$/, ':\1').split(/:/)[1]}' target='_blank'>#{itm.token_stream.first.text.sub(/^# File /, '').sub(/, line (\d+)$/, ':\1')}</a></b></li></ol></td>" : "")
    end

    # builds a method error HTML column
    # <b>itm</b>:: method error item
    def build_alternate_method_error_column(itm)
      ((itm.comment.nil? || itm.comment == '') ? "<li><b>#{itm.name}</b> in <a href='xdoclet/#{itm.token_stream.first.text.sub(/^# File /, '').sub(/, line (\d+)$/, '').gsub(/\//,'_')}.html##{itm.token_stream.first.text.sub(/^# File /, '').sub(/, line (\d+)$/, ':\1').split(/:/)[1]}' target='_blank'>#{itm.token_stream.first.text.sub(/^# File /, '').sub(/, line (\d+)$/, ':\1')}</a></b></li>" : "")
    end

    # determines if a documentation value contains a class error
    # <b>value</b>:: documentation value
    def class_error_present?(value)
      (value.comment.nil? or value.comment == '') unless value.is_a?(Dcov::TopLevel)
    end

    # determines if an error is present in the parameters
    # <b>class_error_presence</b>:: wether a class error is present or not
    # <b>method_error_presence</b>:: wether a method error is present or not
    # <b>value</b>:: an hypotetical documentation error
    def error_present_in?(class_error_presence, method_error_presence, value)
      class_error_presence == true or method_error_presence == true and !value.in_files.first.nil?
    end

    # builds the method errors list
    # <b>method_errors</b>:: method errors array
    def build_error_methods_list(method_errors)
      output = "<td><ol>"
      method_errors.each do |itm|
        output << build_alternate_method_error_column(itm)
      end
      output << "</ol></td>"
    end

    def build_stats_body
      num_classes = find_in_rdoc_log("Classes")
      num_modules = find_in_rdoc_log("Modules")
      num_methods = find_in_rdoc_log("Methods")
      global_coverage = ((class_coverage.to_f * num_classes) + (module_coverage.to_f * num_modules) + (method_coverage.to_f * num_methods)) / (num_classes + num_modules + num_methods)
      output = build_summary(global_coverage, class_coverage, module_coverage, method_coverage)

      if data[:structured].length > 0
        output << "<h3>Details</h3><p><table class='bodyTable'><tr><th>Class/Module name</th><th>Method name</th></tr>\n"
      end
      indice = 0
      nbtr = 0
      data[:structured].each do |key,value|
        class_error_presence = class_error_present?(value[0])
        method_error_presence = false
        count_method_error_presence = 0
        value[1].each do |itm|
          method_error_presence = true if (itm.comment.nil? or itm.comment == '')
          count_method_error_presence += 1 if (itm.comment.nil? or itm.comment == '')
        end
        if class_error_presence == true or method_error_presence == true
          nbtr += 1
          output << "<tr class='#{indice % 2 == 0 ? 'a' : 'b'}'>"
          if error_present_in?(class_error_presence, method_error_presence, value[0])
            output << build_class_error_column(class_error_presence, key, value)
          else
            output << "<td>&#160;</td>"
          end
          if count_method_error_presence == 1
            value[1].each do |itm|
              output << build_method_error_column(itm)
            end
          elsif count_method_error_presence > 1
            output << build_error_methods_list(value[1])
          else
            output << "<td>&#160;</td>"
          end
          if class_error_presence == true or method_error_presence == true
            indice += 1
            output << "</tr>"
          end
        end
      end
      if nbtr == 0
        output << "<tr class='a'><td colspan='2'>There is no undocumented Ruby code.</td></tr>"
      end
      output << "</table>"
    end

    def build_stats_footer
      output = ""
      output << "</ol>\n\n</body></html>"
    end

  end

  class Analyzer
    def generate
      print "Generating dcov report..."

      generator = Dcov::Generator.new @stats.renderable_data
      report = generator.to_s
      print "done.\n"

      print "Writing report..."
      FileUtils.mkdir("#{Continuous4r::WORK_DIR}/dcov")
      if (!File.exists?("#{Continuous4r::WORK_DIR}/dcov/coverage.html")) || (File.writable?("#{Continuous4r::WORK_DIR}/dcov/coverage.html"))
        output_file = File.open("#{Continuous4r::WORK_DIR}/dcov/coverage.html", "w")
        output_file.write report
        output_file.close
        print "done.\n"
      else
        raise "Can't write to [#{Continuous4r::WORK_DIR}/dcov/coverage.html]."
      end
    end
  end
end

# ==========================================================================
# Construction de la tache dcov (couverture rdoc)
# author: Vincent Dubois
# date: 06 fevrier 2009
# ==========================================================================
class DcovBuilder

  # Implementation de la construction de la tache
  def build(project_name, auto_install, proxy_option)
    # On lance la generation
    puts " Building dcov rdoc coverage report..."
    files = Array.new
    files << Dir.glob("app/**/*.rb")
    files << Dir.glob("lib/**/*.rb")
    files.flatten!
    options = {
      :path => '.',
      :output_format => 'html',
      :files => files
    }
    Dcov::Analyzer.new(options)
    if !File.exist?("#{Continuous4r::WORK_DIR}/dcov/coverage.html")
      raise " Execution of dcov failed.\n BUILD FAILED."
    end
  end

  # Methode qui permet d'extraire le pourcentage de qualite extrait d'un builder
  def quality_percentage
    require 'hpricot'
    doc = Hpricot(File.read("#{Continuous4r::WORK_DIR}/dcov/coverage.html"))
    doc.search('//h3') do |h3|
      if h3.inner_text.match(/^Global coverage percentage/)
        return h3.inner_text.split(/Global coverage percentage : /)[1].split(/%/)[0]
      end
    end
  end

  # Nom de l'indicateur de qualite
  def quality_indicator_name
    "rdoc coverage"
  end
end

