# ===========================================================================
#  Construction de la tache changelog (changements du referentiel de sources)
#  author: Vincent Dubois
#  date: 18 fevrier 2009
# ===========================================================================
class ChangelogBuilder
  include Utils

  # Implementation de la construction de la tache
  def build(project_name, scm, auto_install, proxy_option)
    unless File.exist?(".svn") or File.exist?(".git")
      puts " Only Subversion and Git are supported. The 'changelog' task will be empty."
      break
    end
    # On verifie l'existence de Subversion
    scm_name = "svn"
    if File.exist?(".git")
      scm_name = "git"
    end
    scm_version = Utils.run_command("#{scm_name} --version")
    if scm_version.blank?
      if scm_name == "svn"
        raise " Subversion don't seem to be installed. Go see Subversion website on http://subversion.tigris.org.\n BUILD FAILED"
      else
        raise " Git don't seem to be installed. Go see Git website on http://git-scm.com/.\n BUILD FAILED"
      end
    end
    # Gestion de la derniere version
    # 1 - On verifie le repertoire home/continuous4r
    unless File.exist?(ENV["HOME"] + "/.continuous4r")
      Dir.mkdir(ENV["HOME"] + "/.continuous4r")
    end
    # 2 - On verifie le numero de version
    scm_current_version = "1"
    scm_last_version = 1
    if File.exist?(ENV["HOME"] + "/.continuous4r/#{project_name}_#{scm_name}.version")
      scm_current_version = File.read(ENV["HOME"] + "/.continuous4r/#{project_name}_#{scm_name}.version")
    end
    # 3 - On extrait les informations du referentiel
    if scm_name == "svn"
      scm_last_version = SubversionExtractor.extract_changelog(scm_current_version.to_i, scm, "changelog.html")
    elsif scm_name == "git"
      scm_last_version = GitExtractor.extract_changelog(scm_current_version.to_i, scm, "changelog.html")
    end
    # 4 - On ecrit le nouveau numero de revision
    rev_file = File.open(ENV["HOME"] + "/.continuous4r/#{project_name}_#{scm_name}.version","w")
    rev_file.write(scm_last_version)
    rev_file.close
  end
end