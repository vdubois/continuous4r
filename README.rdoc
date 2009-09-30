= continuous4r

* http://continuous4r.rubyforge.org
* http://github.com/vdubois/continuous4r/tree/master
* http://collaborateurvdu.wordpress.com

== DESCRIPTION:

Continuous integration tool which regroups in one place tests, quality and analysis tools in a Maven-like website.

== TODO:
* Make continuous4r like autotest
* Make Roodi produce an indicator

== FEATURES/PROBLEMS:

* See http://continuous4r.rubyforge.org

== SYNOPSIS:

  cd /path/to/rails/app
  add : require 'continuous4r' to your Rakefile
  if you want to run continuous4r:autometrics to constantly check your code while you make modification, add your project configuration (see below)
  Type 'rake continuous4r:build' to build or type 'rake continuous4r:autometrics' for continuous development build
  When continuous4r:build is done, open tmp/continuous4r/index.html in your browser

== AUTOMETRICS CONFIGURATION

Here is a typical configuration example you might code within you Rakefile :

Continuous4rProject.configure do |config|
  config.notify :system => 'libnotify' # libnotify (linux), console
  config.all :detailed => true, :files => ['^app/(.*)\.rb', '^lib/(.*)\.rb'] # apply these options to all tasks
  config.flog
  config.dcov :required => 90 # notify only if documentation coverage is under 90%
  config.flay :mass => 40 # notify only if duplication mass is above 40
  config.rcov :required => 80 # notify only if test coverage is under 80%
  config.reek
  config.roodi
  config.saikuro :warning => 5, :error => 7 # notify with warning if a cyclomatic complexity with 5 value is detected and with an error if 7 is detected
  config.tests :rspec => false # executes test::unit tests or rspec tests
  config.zentest
end

== REQUIREMENTS:

* RubyGems
* rails (erb) for continuous4r:build
* hpricot for continuous4r:build
* mynyml-watchr for continuous4r:autometrics

== INSTALL:

* sudo gem install continuous4r

== LICENSE:

(The MIT License)

Copyright (c) 2009 Vincent Dubois

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
