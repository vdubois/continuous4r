# Tache Rake pour la construction du site Continuous4R
namespace :continuous4r do
  desc 'Clean any continuous4r builds'
  task :clean do
    if File.exist?(Continuous4r::WORK_DIR)
      FileUtils.rm_rf(Continuous4r::WORK_DIR)
    end
  end

  desc 'Build continuous4r Website for the current project'
  task :build do
    Continuous4r.generate_site
  end
end

