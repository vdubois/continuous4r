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
end
