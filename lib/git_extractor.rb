# ====================================================
# Classe d'extraction des informations de Git
# Author: Vincent Dubois
# Date: 19 fevrier 2009
# ====================================================
module GitExtractor
  
  # converts a letter into file status
  # <b>letter</b>:: the letter to convert
  def get_file_status(letter)
    file_status = "added"
    if letter == 'A'
      file_status = "added"
    elsif letter == 'M'
      file_status = "modified"
    elsif letter == 'D'
      file_status = "deleted"
    end
  end

  # generates the computing logs for GIT
  def puts_computing_log
    begin
      git_url = File.read(".git/config").split(/$/).select {|l| l =~ /url = /}[0].split(/url = /)[1]
      git_http_url = git_url.gsub(/git:\/\//, "http://").gsub(/\.git/, "/commit/")
      puts " Computing changelog for #{git_url}..."
    rescue
      puts " Computing changelog, from commit #{scm_current_version} to revision #{revision}..."
    end
  end

  # Methode qui permet de fabriquer le flux HTML a partir des informations
  # presentes dans le referentiel
  def self.extract_changelog scm_current_version, file_name
    git_revisions = Utils.run_command("git log").split(/$/).select{ |l| l =~ /^commit / }.collect { |l| l[8..(l.length-1)] }
    revision = git_revisions[0]
    puts_computing_log
    i = 0
    html = "<table class='bodyTable'><thead><th>Commit</th><th>Date</th><th>Author</th><th>File(s)</th><th>Comment</th></thead><tbody>"
    commits = Utils.run_command("git log --name-status").split(/^commit/)
    commits.delete_at(0)
    index = 0
    commits.each do |commit|
      commit_details = commit.split(/$/)
      next if commit_details[1].strip.split(/Author: /)[1].nil?
      puts " Changelog for commit #{commit_details[0].strip}..."
      html << "<tr class='#{ index % 2 == 0 ? 'a' : 'b'}'><td><strong><a href='#{git_http_url}#{commit_details[0].strip}' target='_blank'>#{commit_details[0].strip}</a></strong></td><td>#{commit_details[2].strip.split(/Date:   /)[1]}</td><td>#{commit_details[1].strip.split(/Author: /)[1]}</td><td>"
      (6..(commit_details.length - 3)).to_a.each do |file_detail|
        file_status = get_file_status(commit_details[file_detail].strip.at(0))
        next if commit_details[file_detail].strip.split(Regexp.new("\t"))[1].nil?
        html << "<img src='images/#{file_status}.png' align='absmiddle'/>&#160;#{commit_details[file_detail].strip.split(Regexp.new("\t"))[1]}<br/>"
      end
      html << "</td><td>#{commit_details[4].strip}</td></tr>"
      index += 1
    end
    html << "</tbody></table>"
    changelog_file = File.open(file_name,"w")
    changelog_file.write(html)
    changelog_file.close
    return revision
  end

end
