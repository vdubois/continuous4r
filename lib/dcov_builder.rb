require 'dcov'

# ==========================================================================
#  Surcharge du module Dcov pour l'adapter aux besoins de continous4r
#  author: Vincent Dubois
#  date: 10 fevrier 2009
# ==========================================================================
module Dcov
  # Generates HTML output
  class Generator # < Ruport::Formatter::HTML
    # renders :html, :for => StatsRenderer

    include Dcov::StatsRenderer::Helpers

    attr_reader :data
    def initialize(data)
      @data = data
    end

    def to_s
      build_stats_header +  build_stats_body + build_stats_footer
    end

    def build_stats_header
      # Little CSS, a little HTML...
      output = ""
      output << """<h2>Dcov results</h2>\n\n<p><a href='http://dcov.rubyforge.org' target='_blank'>Dcov</a> is a documentation coverage analyzer for ruby.</p>"""
    end

    def build_stats_body
      output = ""
      output << "<h3>Summary</h3><p>\n"
      output << "<table class='bodyTable' style='width: 200px;'><tr><th>Type</th><th>Coverage</th></tr>"
      output << "<tr class='a'><td><b>Class</b></td><td style='text-align: right;'>#{class_coverage}%</td></tr>\n"
      output << "<tr class='b'><td><b>Module</b></td><td style='text-align: right;'>#{module_coverage}%</td></tr>\n"
      output << "<tr class='a'><td><b>Method</b></td><td style='text-align: right;'>#{method_coverage}%</td></tr></table>\n"
      output << "</p>\n\n"

      if data[:structured].length > 0
        output << "<h3>Details</h3><p><table class='bodyTable'><tr><th>Class/Module name</th><th>Method name</th></tr>\n"
      end
      indice = 0
      nbtr = 0
      data[:structured].each do |key,value|
        class_error_presence = (value[0].comment.nil? or value[0].comment == '') unless value[0].is_a?(Dcov::TopLevel)
        method_error_presence = false
        count_method_error_presence = 0
        value[1].each do |itm|
          method_error_presence = true if (itm.comment.nil? or itm.comment == '')
          count_method_error_presence += 1 if (itm.comment.nil? or itm.comment == '')
        end
        if class_error_presence == true or method_error_presence == true
          nbtr += 1
          output << "<tr class='#{indice % 2 == 0 ? 'a' : 'b'}'>"
          if class_error_presence == true or method_error_presence == true
            output << "<td>#{"<b>" if class_error_presence == true}#{key.is_a?(String) ? key : key.full_name  }#{"</b> in <a href='xdoc/#{value[0].in_files.first.file_absolute_name.gsub(/\//,'_')}.html' target='_blank'>#{value[0].in_files.first.file_absolute_name}</a>" if class_error_presence == true}</td>"
          else
            output << "<td>&#160;</td>"
          end
          if count_method_error_presence == 1
            value[1].each do |itm|
              output << ((itm.comment.nil? || itm.comment == '') ? "<td><ol><li><b>#{itm.name}</b> in <a href='xdoc/#{itm.token_stream.first.text.sub(/^# File /, '').sub(/, line (\d+)$/, '').gsub(/\//,'_')}.html' target='_blank'>#{itm.token_stream.first.text.sub(/^# File /, '').sub(/, line (\d+)$/, ':\1')}</a></b></li></ol></td>" : "")
#          # Quality information
#          output << "#{"<br /><span class='quality_problem'>parameters without documentation: <tt>" + itm.reporting_data[:parameters_without_coverage].join(", ") + "</tt></span>" if itm.reporting_data[:parameters_without_coverage].length > 0}"
#          output << "#{"<br /><span class='quality_problem'>default values without documentation: <tt>" + itm.reporting_data[:default_values_without_coverage].join(", ") + "</tt></span>" if itm.reporting_data[:default_values_without_coverage].length > 0}"
#          output << "#{"<br /><span class='quality_problem'>options are not documented</span>" if itm.reporting_data[:no_options_documentation]}"
#          output << "#{"<br /><span class='quality_problem'>there are no examples</span>" if itm.reporting_data[:no_examples]}"
#
#          output << "</li>\n"
            end
          elsif count_method_error_presence > 1
            output << "<td><ol>"
            value[1].each do |itm|
              output << ((itm.comment.nil? || itm.comment == '') ? "<li><b>#{itm.name}</b> in <a href='xdoc/#{itm.token_stream.first.text.sub(/^# File /, '').sub(/, line (\d+)$/, '').gsub(/\//,'_')}.html' target='_blank'>#{itm.token_stream.first.text.sub(/^# File /, '').sub(/, line (\d+)$/, ':\1')}</a></b></li>" : "")
#              location = itm.token_stream.first.text.sub(/^# File /, '').sub(/, line (\d+)$/, ':\1')
#              output << "<br/>#{location}"
#          # Quality information
#          output << "#{"<br /><span class='quality_problem'>parameters without documentation: <tt>" + itm.reporting_data[:parameters_without_coverage].join(", ") + "</tt></span>" if itm.reporting_data[:parameters_without_coverage].length > 0}"
#          output << "#{"<br /><span class='quality_problem'>default values without documentation: <tt>" + itm.reporting_data[:default_values_without_coverage].join(", ") + "</tt></span>" if itm.reporting_data[:default_values_without_coverage].length > 0}"
#          output << "#{"<br /><span class='quality_problem'>options are not documented</span>" if itm.reporting_data[:no_options_documentation]}"
#          output << "#{"<br /><span class='quality_problem'>there are no examples</span>" if itm.reporting_data[:no_examples]}"
#
#          output << "</li>\n"
            end
            output << "</ol></td>"
          else
            output << "<td>&#160;</td>"
          end
          if class_error_presence == true or method_error_presence == true
            indice += 1
            output << "</tr>"
          end
        elsif class_error_presence == false and method_error_presence == false
          #output << "<tr class='a'><td colspan='2'>There is no undocumented Ruby code.</td></tr>"
#        else
#          puts value[0].class
#          output << "<tr class='a'><td colspan='2'>There is no undocumented Ruby code.</td></tr>"
        end
      end
      if nbtr == 0
        output << "<tr class='a'><td colspan='2'>There is no undocumented Ruby code.</td></tr>"
      end
      output << "</table>"
      output
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
#  Construction de la tache dcov (couverture rdoc)
#  author: Vincent Dubois
#  date: 06 fevrier 2009
# ==========================================================================
class DcovBuilder
  include Utils

  # Implementation de la construction de la tache
  def build(project_name, scm, auto_install, proxy_option)
    # On verifie la presence de dcov
    Utils.verify_gem_presence("dcov", auto_install, proxy_option)
    # On lance la generation
    puts " Building dcov rdoc coverage report..."
    files = Array.new
    files << Dir.glob("app/**/*.rb")
    files << Dir.glob("lib/**/*.rb")
    files.flatten!
    options = {
      :path     => RAILS_ROOT,
      :output_format => 'html',
      :files => files
    }
    Dcov::Analyzer.new(options)
    if !File.exist?("./coverage.html")
      raise " Execution of dcov failed with command 'dcov -p app/**/*.rb'.\n BUILD FAILED."
    end
  end
end
