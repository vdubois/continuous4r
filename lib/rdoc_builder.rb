require 'utils.rb'

# ==========================================================================
#  Construction de la tache rdoc (apidoc)
#  author: Vincent Dubois
#  date: 06 fevrier 2009
# ==========================================================================
class RdocBuilder
  include Utils

  # Implementation de la construction de la tache
  def build(project_name, scm, auto_install, proxy_option)
    # On lance la generation
    puts " Building rdoc api and rdoc generation report..."
    File.delete("rdoc.log") if File.exist?("rdoc.log")
    rdoc_pass = system("rake doc:reapp > rdoc.log")
    if !rdoc_pass
      raise " Execution of rdoc failed with command 'rake doc:reapp'.\n BUILD FAILED."
    end
    # On recupere la documentation et le fichier de log generes
    Dir.mkdir "#{Continuous4r::WORK_DIR}/rdoc"
    FileUtils.mv("doc/app/", "#{Continuous4r::WORK_DIR}/rdoc/")
    FileUtils.mv("rdoc.log", "#{Continuous4r::WORK_DIR}/rdoc/")
  end
end