# PlatoDevice::TSL2591 class

class I
  attr_accessor :data
  def initialize(addr)
    @addr = addr
    @data = []
  end
  def read(reg, len, type=:as_array)
    d = []
    len.times {d << @data.shift}
    return d if type == :as_array
    s = ''
    d.each {|b| s << b.chr}
    s
  end
  def write(reg, data); data; end
end
module PlatoDevice
  class TSL2591
    attr_reader :i2c
  end
end

assert('TSL2591', 'class') do
  assert_equal(PlatoDevice::TSL2591.class, Class)
end

assert('TSL2591', 'superclass') do
  assert_equal(PlatoDevice::TSL2591.superclass, Plato::Sensor)
end

assert('TSL2591', 'new') do
  Plato::I2C.register_device(I)
  h1 = PlatoDevice::TSL2591.new
  h2 = PlatoDevice::TSL2591.new(1)
  h3 = PlatoDevice::TSL2591.new(PlatoDevice::TSL2591::I2CADDR, 5)
  assert_true(h1 && h2 && h3)
end

assert('TSL2591', 'new - argument error') do
  Plato::I2C.register_device(I)
  assert_raise(ArgumentError) {PlatoDevice::TSL2591.new(1, 2, 3)}
end

assert('TSL2591', 'read') do
  Plato::I2C.register_device(I)
  sen = PlatoDevice::TSL2591.new
  sen.i2c.data = [0x11, 0x22, 0x33, 0x44]
  assert_nothing_raised {sen.read}
end
