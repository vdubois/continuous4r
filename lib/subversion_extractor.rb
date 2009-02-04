require 'iconv'
# ====================================================
# Classe d'extraction des informations de Subversion
# Author: Vincent Dubois
# ====================================================
module SubversionExtractor
  
  # Methode qui permet de fabriquer le flux HTML a partir des informations
  # presentes dans le referentiel
  def self.extract_changelog scm_current_version, scm, file_name
    post_command= ""
    begin
      post_command = post_command + " --username " + scm.user.text
      post_command = post_command + " --password " + scm.password.text
    rescue
      post_command = ""
    end
    get_head_log = `svn log -r 'HEAD'#{post_command}`
    get_head_log_lines = get_head_log.split(/$/)
    revision = get_head_log_lines[1].split(/ \| /)[0]
    revision = revision[2..(revision.length-1)]
    puts " Computing changelog for #{scm.url.text}, from revision #{scm_current_version} to revision #{revision}..."
    i = 0
    html = "<table class='bodyTable'><thead><th>Revision</th><th>Date</th><th>Author</th><th>File(s)</th><th>Comment</th></thead><tbody>"
    (scm_current_version.to_i..revision.to_i).to_a.reverse_each do |rev|
      puts " Changelog for revision #{rev}..."
      rev_files = Array.new
      if rev == 1 or (!scm['min_revision'].nil? and rev == scm['min_revision'].to_i)
        rev_result = `svn diff -r #{rev}#{post_command}|grep ^Index:`
      else
        rev_result = `svn diff -r #{rev-1}:#{rev} --summarize#{post_command}`
      end
      rev_result_lines = rev_result.split(/$/)
      rev_result_lines.each do |line|
        rev_files.push line[7..(line.length-1)]
      end
      rev_files.pop
      rev_log_result = `svn log -r #{rev}`
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
