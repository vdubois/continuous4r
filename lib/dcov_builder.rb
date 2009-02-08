require 'utils.rb'

# ==========================================================================
#  Construction de la tache dcov (couverture rdoc)
#  author: Vincent Dubois
#  date: 06 fevrier 2009
# ==========================================================================
class DcovBuilder
  include Utils

  # Implementation de la construction de la tache
  def build(project_name, scm, auto_install, proxy_option)
    # On verifie la presence de dcov
    Utils.verify_gem_presence("dcov", auto_install, proxy_option)
    # On lance la generation
    puts " Building dcov rdoc coverage report..."
    dcov_pass = system("dcov -p app/**/*.rb")
    if !dcov_pass and !File.exist?("./coverage.html")
      raise " Execution of dcov failed with command 'dcov -p app/**/*.rb'.\n BUILD FAILED."
    end
  end
end