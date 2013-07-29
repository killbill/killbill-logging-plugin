version = File.read(File.expand_path('../VERSION', __FILE__)).strip

Gem::Specification.new do |s|
  s.name        = 'klogger'
  s.version     = version
  s.summary     = 'Plugin to log Kill Bill events.'
  s.description = 'Log all events generated by Kill Bill.'

  s.required_ruby_version = '>= 1.9.3'

  s.license = 'Apache License (2.0)'

  s.author   = 'Kill Bill core team'
  s.email    = 'killbilling-users@googlegroups.com'
  s.homepage = 'http://kill-bill.org'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.bindir        = 'bin'
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.rdoc_options << '--exclude' << '.'

  s.add_dependency 'killbill', '~> 1.4.0'
  s.add_dependency 'cinch', '~> 2.0.3'
  s.add_dependency 'mail', '~> 2.5.3'

  s.add_development_dependency 'jbundler', '~> 0.4.1'
  s.add_development_dependency 'rake', '>= 10.0.0'
  s.add_development_dependency 'rack', '>= 1.5.2'
  s.add_development_dependency 'rspec', '~> 2.12.0'
end
