class DcovBuilder
  def build(project_name, scm, auto_install, proxy_option)
    # On verifie la presence de dcov
    dcov_version = run_command("gem list dcov")
    if dcov_version.blank?
      if auto_install == "true"
        puts " Installing dcov..."
        dcov_installed = run_command("#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install dcov#{proxy_option}")
        if dcov_installed.index("1 gem installed").nil?
          raise " Install for dcov failed with command '#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install dcov#{proxy_option}'\n BUILD FAILED."
        end
      else
        raise " You don't seem to have dcov installed. You can install it with '#{"sudo " unless Config::CONFIG['host_os'] =~ /mswin/}gem install dcov#{proxy_option}'.\n BUILD FAILED."
      end
    end
    # On lance la generation
    puts " Building dcov rdoc coverage report..."
    dcov_pass = system("dcov -p app/**/*.rb")
    if !dcov_pass and !File.exist?("./coverage.html")
      raise " Execution of dcov failed with command 'dcov -p app/**/*.rb'.\n BUILD FAILED."
    end
  end
end