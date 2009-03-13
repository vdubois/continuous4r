# ==========================================================================
#  Construction de la tache flog (complexite du code ruby)
#  Code inspired by the metric_fu gem by Jake Scruggs
#  author: Vincent Dubois
#  date: 06 fevrier 2009
# ==========================================================================
class FlogBuilder

  class Page
    attr_accessor :filename, :score, :scanned_methods

    def initialize(score, scanned_methods = [])
      @score = score.to_f
      @scanned_methods = scanned_methods
    end

    def path
      @path ||= File.basename(filename, ".txt") + '.html'
    end

    def to_html
      ERB.new(File.read(File.join(File.dirname(__FILE__), "site/flog_page.html.erb"))).result(binding)
    end

    def average_score
      return 0 if scanned_methods.length == 0
      sum = 0
      scanned_methods.each do |m|
        sum += m.score
      end
      sum / scanned_methods.length
    end

    def highest_score
      scanned_methods.inject(0) do |highest, m|
        m.score > highest ? m.score : highest
      end
    end

  end

  class Operator
    attr_accessor :score, :operator

    def initialize(score, operator)
      @score = score.to_f
      @operator = operator
    end
  end

  class ScannedMethod
    attr_accessor :name, :score, :operators

    def initialize(name, score, operators = [])
      @name = name
      @score = score.to_f
      @operators = operators
    end
  end

  METHOD_LINE_REGEX = /([A-Za-z]+#.*):\s\((\d+\.\d+)\)/
  OPERATOR_LINE_REGEX = /\s+(\d+\.\d+):\s(.*)$/

  def parse(text)
    score = text[/\w+ = (\d+\.\d+)/, 1]
    return nil unless score
    page = Page.new(score)

    text.each_line do |method_line|
     if match = method_line.match(METHOD_LINE_REGEX)
        page.scanned_methods << ScannedMethod.new(match[1], match[2])
      end

      if match = method_line.match(OPERATOR_LINE_REGEX)
        return if page.scanned_methods.empty?
        page.scanned_methods.last.operators << Operator.new(match[1], match[2])
      end
    end
    page
  end

  def save_html(content, file='index.html')
    f = File.open("#{Continuous4r::WORK_DIR}/flog/#{file}", "w")
    f.write(content)
    f.close
  end

  # Implementation de la construction de la tache
  def build(project_name, auto_install, proxy_option)
    # On verifie la presence de flog
    Utils.verify_gem_presence("flog", auto_install, proxy_option)
    # On lance la generation
    puts " Building flog report..."
    FileUtils.mkdir("#{Continuous4r::WORK_DIR}/flog")
    files = Array.new
    files << Dir.glob("app/**/*.rb")
    files << Dir.glob("lib/**/*.rb")
    files << Dir.glob("test/**/*.rb")
    files << Dir.glob("spec/**/*.rb")
    files.flatten!
    files.each do |filename|
      puts "Processing #{filename}..."
      output_dir = "#{Continuous4r::WORK_DIR}/flog/#{filename.split("/")[0..-2].join("/")}"
      FileUtils.mkdir_p(output_dir, :verbose => false) unless File.directory?(output_dir)
      Utils.run_command("flog -a -c #{filename} > #{Continuous4r::WORK_DIR}/flog/#{filename.split('.')[0]}.txt")
    end
    pages = Array.new
    Dir.glob("#{Continuous4r::WORK_DIR}/flog/**/*.txt").each do |filename|
      page = parse(File.read(filename))
      if page
        page.filename = filename
        pages << page
      end
    end
    pages.each do |page|
      save_html(page.to_html, page.path)
    end
    save_html(ERB.new(File.read(File.join(File.dirname(__FILE__), "site/flog.html.erb"))).result(binding))
  end

  # Methode qui permet d'extraire le pourcentage de qualite extrait d'un builder
  def quality_percentage
    require 'hpricot'
    doc = Hpricot(File.read("#{Continuous4r::WORK_DIR}/flog/index.html"))
    doc.search('//h3') do |h3|
      if h3.inner_text.match(/^Project average score/)
        score = h3.inner_text.split(/Project average score : /)[1].to_f
        if score > 100.0
          percent = 0
        elsif score < 11.0
          percent = 100
        else
          percent = ((100.0 - score) * 100.0) / 89.0
        end
        return percent
      end
    end
  end

  # Nom de l'indicateur de qualite
  def quality_indicator_name
    "code complexity"
  end
end
