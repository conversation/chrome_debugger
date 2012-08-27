Gem::Specification.new do |s|
  s.name              = "chrome_debugger"
  s.version           = "0.0.2"
  s.summary           = "Remotely control Google Chrome and extract stats"
  s.description       = "Starts a Google Chrome session. Load pages and examine the results."
  s.authors           = ["Justin Morris","James Healy"]
  s.email             = ["justin.morris@theconversation.edu.au","james.healy@theconversation.edu.au"]
  s.homepage          = "http://github.com/conversation/chrome_debugger"
  s.has_rdoc          = true
  s.rdoc_options      << "--title" << "Chrome Debugger" << "--line-numbers"

  s.add_dependency('eventmachine')
  s.add_dependency('faye')
  s.add_dependency('headless')
  s.add_dependency('librato-metrics')
  s.add_dependency('yajl-ruby')

  s.files             = Dir.glob("{examples,lib}/**/*") + ["README.md", "CHANGELOG"]
  s.required_rubygems_version = ">=1.3.2"
  s.required_ruby_version = ">=1.9.2"
end
