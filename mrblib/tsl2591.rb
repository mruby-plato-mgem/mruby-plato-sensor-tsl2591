#
# PlatoDevice::TSL2591 class
#
module PlatoDevice
  class TSL2591 < Plato::Sensor
    include Plato
    I2CADDR     = 0x29

    # registers
    COMMAND     = 0xa0  # Command bit
    R_ENABLE    = 0x00  # Enable
    R_CTRL      = 0x01  # Control
    R_DEV_ID    = 0x12  # Device ID
    R_DEV_STS   = 0x13  # Device Status
    R_CH0_LOW   = 0x14
    R_CH0_HIGH  = 0x15
    R_CH1_LOW   = 0x16
    R_CH1_HIGH  = 0x17
    # gain
    GAIN = {
      :low    => 0x00,  # Low gain (1 lux)
      :medium => 0x10,  # Medium gain (25 lux) : default
      :high   => 0x20,  # High gain (428 lux)
      :max    => 0x30   # Max gain (9876 lux)
    }
    # timing
    TIMING = {
      :_100ms => 0x00, :_200ms => 0x01, :_300ms => 0x02,
      :_400ms => 0x03, :_500ms => 0x04, :_600ms => 0x05
    }
    # enable parameters
    ENABLE_POWEROFF = 0x00
    ENABLE_POWERON  = 0x01
    ENABLE_AEN      = 0x02
    ENABLE_AIEN     = 0x10
    ENABLE_NPIEN    = 0x80

    LUX_DF    = 408.0
    LUX_COEFB = 1.64    # CH0 coefficient
    LUX_COEFC = 0.59    # CH1 coefficient A
    LUX_COEFD = 0.86    # CH2 coefficient B

    attr_reader :gain
    attr_reader :timing

    def initialize(addr=I2CADDR, ndigits=3)
      @i2c = Plato::I2C.open(addr)
      @ndig = ndigits
      # initialize gain/timing
      control(:medium, :_100ms)
    end

    def read
      lumi = luminosity
      lux = calculate(lumi)
      lux.round(@ndig)
    end

    # set gain
    def gain=(g); control(g, @timing); end

    # set timing
    def timing=(t); control(@gain, t); end

    # private

    def enable
      @i2c.write(COMMAND|R_ENABLE, ENABLE_POWERON|ENABLE_AEN|ENABLE_AIEN|ENABLE_NPIEN)
    end

    def disable
      @i2c.write(COMMAND|R_ENABLE, ENABLE_POWERON)
    end

    def control(g=nil, t=nil)
      g = @gain unless g
      t = @timing unless t
      raise "invalid gain (#{g})" unless GAIN.has_key?(g)
      raise "invalid timing (#{t})" unless TIMING.has_key?(t)
      @gain, @timing = g, t
      # puts "@gain=:#{g}, timing=:#{t}"
      enable
      @i2c.write(COMMAND|R_CTRL, TIMING[t]|GAIN[g])
      disable
    end

    def luminosity
      enable
      Machine.delay((TIMING[@timing] + 1) * 120)  # wait ADC completion
      ch0 = @i2c.read(COMMAND|R_CH0_LOW, 2)
      ch1 = @i2c.read(COMMAND|R_CH1_LOW, 2)
      disable
      # puts "ch0: #{ch0}"
      # puts "ch1: #{ch1}"
      lumi_ch0 = ch0[1] << 8 | ch0[0]
      lumi_ch1 = ch1[1] << 8 | ch1[0]
      lumi = [lumi_ch0, lumi_ch1, lumi_ch0 - lumi_ch1]
      # puts "luminosity: #{lumi}"
      lumi
    end

    def calculate(lumi)
      ch0, ch1, dummy = lumi
      return 0.0 if ch0 == 0xffff && ch1 == 0xffff
      atime = (TIMING[@timing] + 1) * 100
      again = case @gain
        when :low;    1.0
        when :medium; 25.0
        when :high;   428.0
        when :max;    9876.0
        else          1.0
      end
      cpl = atime * again / LUX_DF
      # lux1 = ( (float)ch0 - (TSL2591_LUX_COEFB * (float)ch1) ) / cpl;
      lux1 = (ch0 - LUX_COEFB * ch1.to_f) / cpl
      # lux2 = ( ( TSL2591_LUX_COEFC * (float)ch0 ) - ( TSL2591_LUX_COEFD * (float)ch1 ) ) / cpl;
      lux2 = (LUX_COEFC * ch0.to_f - LUX_COEFD * ch1.to_f) / cpl
      # puts "lux1=#{lux1}"
      # puts "lux2=#{lux2}"
      lux = lux1 > lux2 ? lux1 : lux2
      # puts "lux=#{lux}"
      lux
    end
  end
end
