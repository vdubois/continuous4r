# ==========================================================================
#  Construction de la tache xdoclet (transformation du code Ruby en HMTL)
#  author: Vincent Dubois
#  date: 07 fevrier 2009
# ==========================================================================
class XdocletBuilder
  include Utils

  # Implementation de la construction de la tache
  def build(project_name, auto_install, proxy_option)
    # Vérification de la presence du gem coderay
    Utils.verify_gem_presence("coderay", auto_install, proxy_option)
    # Generation du rapport pour chaque fichier source ruby
    puts " Building xdoc source report..."
    FileUtils.mkdir("#{Continuous4r::WORK_DIR}/xdoclet")
    files = Array.new
    files << Dir.glob("#{RAILS_ROOT}/app/**/*.rb")
    files << Dir.glob("#{RAILS_ROOT}/app/**/*.html.erb")
    files << Dir.glob("#{RAILS_ROOT}/app/**/*.rhtml")
    files << Dir.glob("#{RAILS_ROOT}/lib/**/*.rb")
    files << Dir.glob("#{RAILS_ROOT}/test/**/*.rb")
    files << Dir.glob("#{RAILS_ROOT}/spec/**/*.rb")
    files.flatten!

    require 'rubygems'
    require 'coderay'
    files.each do |file|
      print "\nProcessing #{file.gsub(Regexp.new("#{RAILS_ROOT}/"),'')}..."
      scanner = :rhtml
      scanner = :ruby if file.match(/\.rb$/)
      # magic
      html_code = CodeRay.scan(File.read(file), scanner).div(:line_numbers => :table, :css => :class)
      html_file = File.open("#{Continuous4r::WORK_DIR}/xdoclet/#{file.gsub(Regexp.new("#{RAILS_ROOT}/"),'').gsub(/\//,'_')}.html", "w")
      html_global_code = "<html><head><title>Source code for #{file.gsub(Regexp.new("#{RAILS_ROOT}/"),'')}</title>"
      html_global_code = html_global_code + "<style>#{File.read("#{File.dirname(__FILE__)}/site/style/coderay.css")}</style>"
      html_global_code = html_global_code + "<body><span style='font-family: Arial, Verdana, Helvetica; color: brown; font-weight: bold; font-size: 18px;'>Source code for #{file.gsub(Regexp.new("#{RAILS_ROOT}/"),'')}</span><br/><br/>#{html_code}</body></html>"
      html_file.write(html_global_code)
      html_file.close
    end
  end
end

