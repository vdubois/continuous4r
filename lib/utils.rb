# Module de fonctions utilitaires necessaire a la construction
module Utils

  # Methode qui permet de construire une page avec eruby, et de lever une exception au besoin
  def self.erb_run page, is_a_task = true
    page_file = File.open("#{Continuous4r::WORK_DIR}/#{page}.html", "w")
    erb = ERB.new(File.read("#{File.dirname(__FILE__)}/site/header.rhtml"))
    page_file.write(erb.result)
    if is_a_task == true
      erb = ERB.new(File.read("#{File.dirname(__FILE__)}/site/menu-task.rhtml"), 0, "%<>")
      current_task = page
      page_file.write(erb.result(binding))
    else
      erb = ERB.new(File.read("#{File.dirname(__FILE__)}/site/menu-#{page}.rhtml"), 0, "%<>")
      page_file.write(erb.result)
    end
    erb = ERB.new(File.read("#{File.dirname(__FILE__)}/site/body-#{page}.rhtml"))
    page_file.write(erb.result)
    page_file.close
  end

  # Methode qui permet de lancer une ligne de commande et de renvoyer son resultat
  def self.run_command(cmd)
    if Config::CONFIG['host_os'] =~ /mswin/
      `cmd.exe /C #{cmd}`
    else
      `#{cmd}`
    end
  end

  # Methode de verification de la presence d'un gem, avec installation au besoin
  def self.verify_gem_presence(gem, auto_install, proxy_option)
    gem_version = run_command("gem list #{gem}")
    if gem_version.nil? or gem_version.strip.empty?
      if auto_install == "true"
        puts " Installing #{gem}..."
        gem_installed = Utils.run_command("#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install #{gem}#{proxy_option}")
        if gem_installed.index("installed").nil?
          raise " Install for #{gem} failed with command '#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install #{gem}#{proxy_option}'\n BUILD FAILED."
        end
      else
        raise " You don't seem to have #{gem} installed. You can install it with '#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install #{gem}#{proxy_option}'.\n BUILD FAILED."
      end
    end

  end

  # Methode qui permet de convertir un pourcentage d'un builder en couleur css/html
  def self.percent_to_css_style(percent)
    style = "style='font-weight: bold; color: "
    if percent >= 90 and percent <= 100
      style += "#00cc00;'"
    elsif percent >= 80 and percent < 90
      style += "orange;'"
    elsif percent >= 60 and percent < 80
      style += "red;'"
    elsif percent >= 0 and percent < 60
      style += "red; text-decoration: blink;'"
    end
    return style
  end

  # Methode qui permet de convertir un pourcentage d'un builder en couleur css/html
  def self.heading_for_builder(heading_title, percent)
    html = "<h3 style=\""
    if percent >= 90 and percent <= 100
      html += "padding-left: 35px; background-image: url('images/accept.png'); background-repeat: no-repeat; background-position: 10px 50%; font-weight: bold; background-color: #e3ffdb; color: #7ab86c;"
    elsif percent >= 75 and percent < 90
      html += "padding-left: 35px; background-image: url('images/error.png'); background-repeat: no-repeat; background-position: 10px 50%; font-weight: bold; background-color: #fffccf; color: #666600;"
    elsif percent >= 60 and percent < 75
      html += "padding-left: 35px; background-image: url('images/exclamation.png'); background-repeat: no-repeat; background-position: 10px 50%; font-weight: bold; background-color: #ffdddd; color: #770000;"
    elsif percent >= 0 and percent < 60
      html += "padding-left: 35px; background-image: url('images/exclamation.png'); background-repeat: no-repeat; background-position: 10px 50%; font-weight: bold; background-color: #ffdddd; color: #770000; text-decoration: blink;"
    end
    html += "\">#{heading_title}</h3>"
    return html
  end

  # Méthode qui permet de récupérerle numéro de build courant dans le SCM
  def self.build_name
    if File.exist?(".git")
      return "commit #{Utils.run_command("git log").split(/$/).select{ |l| l =~ /^commit / }.collect { |l| l[8..(l.length-1)] }[0]}"
    elsif File.exist?(".svn")
      get_head_log = Utils.run_command("svn log -r HEAD")
      get_head_log_lines = get_head_log.split(/$/)
      revision = get_head_log_lines[1].split(/ \| /)[0]
      revision = revision[2..(revision.length-1)]
      return "revision #{revision}"
    end
  end

  # Méthode qui permet de typer une cellule de table HTML en fonction d'un score flog
  def self.flog_caracteristics(flog_score)
    if flog_score >= 0 and flog_score < 11
      "title='Awesome'"
    elsif flog_score >= 11 and flog_score < 21
      "title='Good enough'"
    elsif flog_score >= 21 and flog_score < 41
      "style='background-color: #FFFF99; color: black;' title='Might need refactoring'"
    elsif flog_score >= 41 and flog_score < 61
      "style='background-color: yellow; color: black;' title='Possible to justify'"
    elsif flog_score >= 61 and flog_score < 100
      "style='background-color: orange; color: black;' title='Danger'"
    elsif flog_score >= 100 and flog_score < 200
      "style='background-color: red; color: black;' title='Whoop, whoop, whoop'"
    elsif flog_score > 200
      "style='background-color: black; color: white;' title='Someone please think of the children'"
    end
  end

  # Methode qui permet de convertir un score flog en couleur css/html de titre
  def self.flog_score_to_css_style(flog_score)
    style = "style=\"font-weight: bold; "
    if flog_score >= 0 and flog_score < 11
      style += "background-color: #e3ffdb; color: #7ab86c; padding-left: 35px; background-image: url('images/accept.png'); background-repeat: no-repeat; background-position: 10px 50%;\" title='Awesome'"
    elsif flog_score >= 11 and flog_score < 21
      style += "background-color: #e3ffdb; color: #7ab86c; padding-left: 35px; background-image: url('images/accept.png'); background-repeat: no-repeat; background-position: 10px 50%;\" title='Good enough'"
    elsif flog_score >= 21 and flog_score < 41
      style += "background-color: #fffccf; color: #666600; padding-left: 35px; background-image: url('images/error.png'); background-repeat: no-repeat; background-position: 10px 50%;\" title='Might need refactoring'"
    elsif flog_score >= 41 and flog_score < 61
      style += "background-color: #fffccf; color: #666600; padding-left: 35px; background-image: url('images/error.png'); background-repeat: no-repeat; background-position: 10px 50%;\" title='Possible to justify'"
    elsif flog_score >= 61 and flog_score < 100
      style += "background-color: orange; padding-left: 35px; background-image: url('images/error.png'); background-repeat: no-repeat; background-position: 10px 50%;\" title='Danger'"
    elsif flog_score >= 100 and flog_score < 200
      style += "background-color: red; padding-left: 35px; background-image: url('images/exclamation.png'); background-repeat: no-repeat; background-position: 10px 50%;\" title='Whoop, whoop, whoop'"
    elsif flog_score > 200
      style += "background-color: red; color: black; text-decoration: blink; padding-left: 35px; background-image: url('images/exclamation.png'); background-repeat: no-repeat; background-position: 10px 50%;\" title='Someone please think of the children'"
    end
    return style
  end
end

class String
  # method to sanitize a string found on a terminal output
  def sanitize_from_terminal_to_html
    self.gsub(//,"").gsub(/\[31m/, "").gsub(/\[32m/, "").gsub(/\[35m/, "").gsub(/\[0m/, "")
  end
end

