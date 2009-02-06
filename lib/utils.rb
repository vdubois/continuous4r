# Module de fonctions utilitaires necessaire a la construction
module Utils

  # Methode qui permet de construire une page avec eruby, et de lever une exception au besoin
  def self.erb_run page
    page_file = File.open("#{Continuous4r::WORK_DIR}/#{page}.html", "w")
    erb = ERB.new(File.read("#{File.dirname(__FILE__)}/site/header.rhtml"))
    page_file.write(erb.result)
    erb = ERB.new(File.read("#{File.dirname(__FILE__)}/site/menu-#{page}.rhtml"))
    page_file.write(erb.result)
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
  
end
