require 'iconv'

# ====================================================
# Classe d'extraction des informations de Subversion
# Author: Vincent Dubois
# Date: 19 fevrier 2009
# ====================================================
module SubversionExtractor

  # generates a HTML icon for a SVN extracted letter flag
  # <b>letter</b>:: the flag letter (A(dded)/M(odified)/D(eleted))
  def letter_as_icon(letter)
    if line[0..0] == 'A'
      text = "<img src='images/added.png' align='absmiddle'/>"
    elsif line[0..0] == 'M'
      text = "<img src='images/modified.png' align='absmiddle'/>"
    elsif line[0..0] == 'D'
      text = "<img src='images/deleted.png' align='absmiddle'/>"
    end
  end

  # extract files from a given revision
  # <b>rev</b>:: the given revision
  def extract_revision_files(rev)
    rev_files = Array.new
    if rev == 1
      rev_result = Utils.run_command("svn diff -r 1").split(/$/).select{ |l| l =~ /^Index:/ }
      rev_result.each do |line|
        rev_files.push "<img src='images/added.png' align='absmiddle'/>#{line[8..(line.length-1)]}"
      end
    else
      rev_result = Utils.run_command("svn diff -r #{rev-1}:#{rev} --summarize")
      if !rev_result.match(/^svn:/)
        rev_result_lines = rev_result.split(/$/).collect { |l| l.gsub(Regexp.new("\n"), "") }
        rev_result_lines.each do |line|
          rev_files.push "#{letter_as_icon(line[0..0])}&#160;#{line[7..(line.length-1)]}"
        end
        rev_files.pop
      end
    end
    rev_files
  end

  # build the details of changelog for a revision
  # <b>rev</b>:: revision number
  # <b>i</b>:: changelog index
  def self.changelog_for_revision(rev, i)
    puts " Changelog for revision #{rev}..."
    rev_files = extract_revision_files(rev)
    rev_log_result = Utils.run_command("svn log -r #{rev}")
    rev_log_result_lines = rev_log_result.split(/$/)
    #next if rev_log_result_lines[1].nil?
    rev_line = rev_log_result_lines[1].split(/ \| /)
    #next if rev_line[2].nil?
    html << "<tr class='#{ i % 2 == 0 ? 'a' : 'b'}'><td><strong>#{rev_line[0][2..(rev_line[0].length-1)]}</strong></td><td>#{rev_line[2][0..18]}</td><td>#{rev_line[1]}</td><td>"
    rev_files.each do |rev_file|
      html << rev_file + "<br/>"
    end
    html << "</td><td>"
    (3..(rev_log_result_lines.length-3)).to_a.each do |line|
      begin
        html << Iconv.conv('ISO-8859-1', 'UTF-8', rev_log_result_lines[line]) + "<br/>"
      rescue
        html << rev_log_result_lines[line] + "<br/>"
      end
    end
    html << "</td></tr>"
  end

  # Methode qui permet de fabriquer le flux HTML a partir des informations
  # presentes dans le referentiel
  # <b>scm_current_version</b>:: current version of SCM
  # <b>file_name</b>:: file name to write
  def self.extract_changelog(scm_current_version, file_name)
    revision = Utils.run_command("svn log -r HEAD").split(/$/)[1].split(/ \| /)[0]
    revision = revision[2..(revision.length-1)]
    scm_current_version = revision.to_i - 10 if revision.to_i - scm_current_version.to_i > 10
    scm_current_version -= 10 if scm_current_version > 10
    svn_info = Utils.run_command("svn info")
    svn_url = svn_info.split(/$/)[1].split(/^URL/)[1].strip.split(/: /)[1]
    puts " Computing changelog for #{svn_url}, from revision #{scm_current_version} to revision #{revision}..."
    i = 0
    html = "<table class='bodyTable'><thead><th>Revision</th><th>Date</th><th>Author</th><th>File(s)</th><th>Comment</th></thead><tbody>"
    (scm_current_version.to_i..revision.to_i).to_a.reverse_each do |rev|
      html << changelog_for_revision(rev, i)
      i += 1
    end
    html << "</tbody></table>"
    changelog_file = File.open(file_name,"w")
    changelog_file.write(html)
    changelog_file.close
    return revision
  end

end

