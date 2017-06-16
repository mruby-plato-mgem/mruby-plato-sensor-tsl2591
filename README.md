# mruby-plato-sensor-tsl2591   [![Build Status](https://travis-ci.org/mruby-plato/mruby-plato-sensor-tsl2591.svg?branch=master)](https://travis-ci.org/mruby-plato/mruby-plato-sensor-tsl2591)
PlatoDevice::TSL2591 class (TSL2591 - Light to digital converter)
## install by mrbgems
- add conf.gem line to `build_config.rb`

```ruby
MRuby::Build.new do |conf|

  # ... (snip) ...

  conf.gem :git => 'https://github.com/mruby-plato/mruby-plato-i2c'
  conf.gem :git => 'https://github.com/mruby-plato/mruby-plato-sensor'
  conf.gem :git => 'https://github.com/mruby-plato/mruby-plato-sensor-tsl2591'
end
```

## example
```ruby
s = Plato::Sensor.new
puts s.read
```

## License
under the MIT License:
- see LICENSE file
