%w[rubygems rake rake/clean fileutils newgem rubigen hoe].each { |f| require f }
require File.dirname(__FILE__) + '/lib/continuous4r'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec(Continuous4r::VERSION) do |p|
  #p.developer('Vincent Dubois', 'duboisv@hotmail.com')
  p.changes              = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  p.post_install_message = 'PostInstall.txt'
  p.rubyforge_name       = p.name
  p.name                 = "continuous4r"
  p.summary		         = "Continuous integration for Ruby on Rails"
  p.description          = "Continuous integration site generation for Ruby on Rails"
  p.url             = "http://continuous4r.rubyforge.org"
  # p.extra_deps         = [
  #   ['activesupport','>= 2.0.2'],
  # ]
  p.extra_dev_deps = [
    ['newgem', ">= #{::Newgem::VERSION}"]
  ]

  p.clean_globs |= %w[**/.DS_Store tmp *.log]
  path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
  p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
  p.rsync_args = '-av --delete --ignore-errors'
end

require 'newgem/tasks' # load /tasks/*.rake

Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# task :default => [:spec, :features]
require 'continuous4r'
c4rproject = Continuous4rProject.new
c4rproject.name = "continuous4r"
c4rproject.tasks = ['flog']
c4rproject.company = Company.new
c4rproject.company.denomination = "SQLI"
c4rproject.company.url = "http://www.sqli.com"
c4rproject.company.logo = "file:///home/vdubois/Bureau/logo-sqli.png"

Continuous4r.project = c4rproject

