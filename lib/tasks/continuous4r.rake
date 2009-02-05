# Tache Rake pour la construction du site Continuous4R
namespace :continuous4r do
  desc 'Clean any continuous4r builds'
  task :clean do
    if File.exist?(Continuous4r::WORK_DIR)
      FileUtils.rm_rf(Continuous4r::WORK_DIR)
    end
  end

  desc 'Initialize your project for continuous4r build'
  task :init do
    if !File.exist?("#{RAILS_ROOT}/continuous4r-project.xml")
      FileUtils.copy_file(File.join(File.dirname(__FILE__), "continuous4r-project.xml"), "#{RAILS_ROOT}/continuous4r-project.xml")
    else
      puts "The continuous4r-project.xml file already exists. Either this project is already configured, or you should delete this file and re-run this command."
    end
  end
  
  desc 'Build continuous4r Website for the current project'
  task :build do
    Continuous4r.generate_site
  end  
end
