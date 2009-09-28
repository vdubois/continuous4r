# ==========================================================================
#  Construction de la tache rdoc (apidoc)
#  author: Vincent Dubois
#  date: 06 fevrier 2009
# ==========================================================================
class RdocBuilder

  # Implementation de la construction de la tache
  def build(project_name, auto_install, proxy_option)
    # On lance la generation
    puts " Building rdoc api and rdoc generation report..."
    project_root = '.'
    if !File.exist?("#{project_root}/doc")
      FileUtils.mkdir("#{project_root}/doc")
    end
    if !File.exist?("#{project_root}/doc/README_FOR_APP")
      if File.exist?("#{project_root}/README")
        FileUtils.copy_file("#{project_root}/README", "#{project_root}/doc/README_FOR_APP")
      else
        FileUtils.touch("#{project_root}/doc/README_FOR_APP")
      end
    end
    File.delete("rdoc.log") if File.exist?("rdoc.log")
    rake_doc_task = "doc:reapp" if File.exist?("#{project_root}/app/controllers/")
    rake_doc_task ||= "docs"
    rdoc_pass = system("rake #{rake_doc_task} > rdoc.log")
    if !rdoc_pass
      raise " Execution of rdoc failed with command 'rake doc:reapp'.\n BUILD FAILED."
    end
    # On recupere la documentation et le fichier de log generes
    FileUtils.mkdir_p "#{Continuous4r::WORK_DIR}/rdoc"
    if File.exists?("app/controllers/")
      FileUtils.mv("doc/app/", "#{Continuous4r::WORK_DIR}/rdoc/", :force => true)
    else
      FileUtils.mv("doc/", "#{Continuous4r::WORK_DIR}/rdoc/", :force => true)
    end
    FileUtils.mv("rdoc.log", "#{Continuous4r::WORK_DIR}/rdoc/", :force => true)
  end
end

