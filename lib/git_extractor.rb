require 'iconv'

# ====================================================
# Classe d'extraction des informations de Git
# Author: Vincent Dubois
# Date: 19 fevrier 2009
# ====================================================
module GitExtractor

  # Methode qui permet de fabriquer le flux HTML a partir des informations
  # presentes dans le referentiel
  def self.extract_changelog scm_current_version, scm, file_name
    git_revisions = Utils.run_command("git log").split(/$/).select{ |l| l =~ /^commit / }.collect { |l| l[8..(l.length-1)] }
    revision = git_revisions[0]
    begin
      git_url = File.read(".git/config").split(/$/).select {|l| l =~ /url = /}[0].split(/url = /)[1]
      puts " Computing changelog for #{git_url}, from commit #{scm_current_version} to revision #{revision}..."
    rescue
      puts " Computing changelog, from commit #{scm_current_version} to revision #{revision}..."
    end
    i = 0
    html = "<table class='bodyTable'><thead><th>Commit</th><th>Date</th><th>Author</th><th>File(s)</th><th>Comment</th></thead><tbody>"
    # TODO A améliorer en dessous
    commits = Utils.run_command("git log --name-status").split(/^commit/)
    commits.pop
    commits.each do |commit|
      lines = commit.split(/$/)
      puts lines
    end
    (scm_current_version.to_i..revision.to_i).to_a.reverse_each do |rev|
      puts " Changelog for commit #{rev}..."
      rev_files = Array.new
      # TODO Dans la suite, gérer les icônes ajout/modif/suppression
      if rev == 1 #or (!scm['min_revision'].nil? and rev == scm['min_revision'].to_i)
        rev_result = Utils.run_command("svn diff -r #{rev}").split(/$/).select{ |l| l =~ /^Index:/ }
        rev_result.each do |line|
          rev_files.push line[8..(line.length-1)]
        end
      else
        rev_result = Utils.run_command("svn diff -r #{rev-1}:#{rev} --summarize")
        rev_result_lines = rev_result.split(/$/)
        rev_result_lines.each do |line|
          rev_files.push line[7..(line.length-1)]
        end
        rev_files.pop
      end
      rev_log_result = Utils.run_command("svn log -r #{rev}")
      rev_log_result_lines = rev_log_result.split(/$/)
      rev_line = rev_log_result_lines[1].split(/ \| /)
      html = html + "<tr class='#{ i % 2 == 0 ? 'a' : 'b'}'><td><strong>#{rev_line[0][2..(rev_line[0].length-1)]}</strong></td>"
      html = html + "<td>#{rev_line[2][0..18]}</td><td>#{rev_line[1]}</td><td>"
      rev_files.each do |rev_file|
        html = html + rev_file + "<br/>"
      end
      html = html + "</td><td>"
      (3..(rev_log_result_lines.length-3)).to_a.each do |line|
        begin
          html = html + Iconv.conv('ISO-8859-1', 'UTF-8', rev_log_result_lines[line]) + "<br/>"
        rescue
          html = html + rev_log_result_lines[line] + "<br/>"
        end
      end
      html = html + "</td></tr>"
      i = i + 1
    end
    html = html + "</tbody></table>"
    changelog_file = File.open(file_name,"w")
    changelog_file.write(html)
    changelog_file.close
    return revision
  end

end
