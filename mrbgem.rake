MRuby::Gem::Specification.new('mruby-plato-sensor-tsl2591') do |spec|
  spec.license = 'MIT'
  spec.authors = 'Plato developers'
  spec.description = 'PlatoDevice::TSL2591 class (TSL2591 - Light to digital converter)'

  spec.add_dependency('mruby-plato-machine')
  spec.add_test_dependency('mruby-plato-machine-sim')
  spec.add_dependency('mruby-plato-i2c')
  spec.add_dependency('mruby-plato-sensor')
end
