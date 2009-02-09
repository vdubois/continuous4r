# ==========================================================================
#  Construction de la tache saikuro (complexité cyclomatique du code)
#  author: Vincent Dubois
#  date: 08 fevrier 2009
# ==========================================================================
class SaikuroBuilder
  include Utils

  # Implementation de la construction de la tache
  def build(project_name, scm, auto_install, proxy_option)
    # On verifie la presence de saikuro
    Utils.verify_gem_presence("Saikuro", auto_install, proxy_option)
    # On lance la generation
    puts " Building saikuro report..."
    puts Utils.run_command("saikuro -c -i app -i lib -i test -y 0 -w 5 -e 7 -o #{Continuous4r::WORK_DIR}/saikuro")
    if !File.exist?("#{Continuous4r::WORK_DIR}/saikuro/index_cyclo.html")
      raise " Execution of saikuro with the metric_fu gem failed.\n BUILD FAILED."
    end
  end
end