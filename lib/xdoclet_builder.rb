# ==========================================================================
#  Construction de la tache xdoclet (transformation du code Ruby en HMTL)
#  author: Vincent Dubois
#  date: 07 fevrier 2009
# ==========================================================================
class XdocletBuilder
  include Utils

  # Implementation de la construction de la tache
  def build(project_name, auto_install, proxy_option)
    # Vérification de la présence du gem syntax
    Utils.verify_gem_presence("syntax", auto_install, proxy_option)
    # Génération du rapport pour chaque fichier source ruby
    puts " Building xdoc source report..."
    FileUtils.mkdir("#{Continuous4r::WORK_DIR}/xdoclet")
    require 'syntax/convertors/html'
    files = Array.new
    files << Dir.glob("#{RAILS_ROOT}/app/**/*.rb")
    files << Dir.glob("#{RAILS_ROOT}/lib/**/*.rb")
    files << Dir.glob("#{RAILS_ROOT}/test/**/*.rb")
    files.flatten!
    convertor = Syntax::Convertors::HTML.for_syntax("ruby")

    files.each do |file|
      print "\nProcessing #{file.gsub(Regexp.new("#{RAILS_ROOT}/"),'')}..."
      ruby_code = File.read(file)
      html_code = convertor.convert(ruby_code)
      # Ajout des numéros de lignes
      html_code_with_lines = ""
      html_code_lines = html_code.split(/$/)
      html_code_lines.each_with_index do |line,index|
        if index == 0
          html_code_with_lines = html_code_with_lines.concat("<pre><a name='#{(index + 1).to_s}'></a><span class='numline'>#{(index + 1).to_s.rjust(4)}  </span>").concat(line.delete("\n").gsub(/<pre>/,'')).concat("\n")
        elsif index == html_code_lines.length - 1
          print "OK"
        else
          html_code_with_lines = html_code_with_lines.concat("<span class='numline'>#{(index + 1).to_s.rjust(4)}  </span><a name='#{(index + 2).to_s}'></a>").concat(line.delete("\n")).concat("\n")
        end
      end
      html_file = File.open("#{Continuous4r::WORK_DIR}/xdoclet/#{file.gsub(Regexp.new("#{RAILS_ROOT}/"),'').gsub(/\//,'_')}.html", "w")
      html_global_code = "<html><head><title>Source code for #{file.gsub(Regexp.new("#{RAILS_ROOT}/"),'')}</title>"
      html_global_code = html_global_code + "<style>#{File.read("#{File.dirname(__FILE__)}/site/syntax_highlighting.css")}</style>"
      html_global_code = html_global_code + "<body><h2>Source code for #{file.gsub(Regexp.new("#{RAILS_ROOT}/"),'')}</h2><br/>#{html_code_with_lines}</body></html>"
      html_file.write(html_global_code)
      html_file.close
    end
  end
end
