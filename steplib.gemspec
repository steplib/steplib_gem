Gem::Specification.new do |s|
  s.name        = 'steplib'
  s.version     = '0.9.0.5'
  s.date        = '2015-01-06'
  s.summary     = "StepLib.com's validator and other utilities GEM"
  s.description = "Validates, converts, etc. a StepLib, Workflow and other steplib datastore formats. This GEM's major and minor version number matches the related StepLib format specification's major and minor version number."
  s.authors     = ["Bitrise", "Viktor Benei"]
  s.email       = 'letsconnect@bitrise.io'
  s.files       = ["lib/steplib.rb"]
  s.files       += Dir['lib/steplib/**/*.rb']
  s.homepage    =
    'https://github.com/steplib/steplib_gem'
  s.license       = 'MIT'
end