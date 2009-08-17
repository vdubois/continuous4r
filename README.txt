= continuous4r

* http://continuous4r.rubyforge.org
* http://github.com/vdubois/continuous4r/tree/master
* http://collaborateurvdu.wordpress.com

== DESCRIPTION:

Continuous integration tool which regroups in one place tests, quality and analysis tools in a Maven-like website.

== TODO:
* Make Roodi produce an indicator
* Make continuous4r fully parameter-able
* Make continuous4r collect statistics over the time

== FEATURES/PROBLEMS:

* See http://continuous4r.rubyforge.org

== SYNOPSIS:

  cd /path/to/rails/app
  add : require 'continuous4r' to your Rakefile
  Type 'rake continuous4r:build' to build
  then open tmp/continuous4r/index.html in your browser

== REQUIREMENTS:

* RubyGems
* rails (erb)
* hpricot

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
