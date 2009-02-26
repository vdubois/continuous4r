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
    if gem_version.blank?
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
      style += "yellow;'"
    elsif percent >= 60 and percent < 80
      style += "red;'"
    elsif percent >= 0 and percent < 60
      style += "red; text-decoration: blink;'"
    end
    return style
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
end
