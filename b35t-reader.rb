#!/usr/bin/env nix-shell
#nix-shell -p ruby bluez -i ruby

mac_address = "98:84:E3:CD:BF:C9"
#i found mac address of my b35t by running `sudo hcitool lescan`
#and it showed up as '<MAC ADDRESS> BDM'

IO.popen("gatttool -b #{mac_address} --char-read --handle 0x2d --listen").each do |line|
  line.chomp
  if ! /Notification handle = 0x002e/.match(line) then
    next
  end

  output = /Notification handle = 0x002e value: (.*)/
            .match(line)[1]
            .split(/ /)
            .map {|x| x.hex }

  digits = output[1..4].map {|x| x.chr}.join("").to_f

  case output[6]
  when 51
    reading = digits/10.0
  when 50
    reading = digits/100.0
  when 49
    reading = digits/1000.0
  else
    reading = digits/1.0
  end

  case output[8]
  when 16
    maxmin = "min"
  when 32
    maxmin = "max"
  else
    maxmin = ""
  end

  case output[7]
  when 0
    mode = ""
  when 1
    mode = "Ohmmanual"
  when 8
    mode = "ACminmax"
    if output[6] == 50 then
      reading = reading* 10.0
    end
  when 9
    mode = "ACmanual"
  when 16
    mode = "DCminmax"
    if output[6] == 50 then
      reading = reading* 10.0
    end
  when 17
    mode = "DCmanual"
    if output[6] == 50 then
      reading = reading* 10.0
    end
  when 20
    mode = "delta"
  when 32
    #this is hz, no ranging.
    mode = ""
  when 33
    #this is hz, no ranging.
    mode = "Ohmauto"
  when 41
    mode = "ACauto"
  when 49
    mode = "DCauto"
    if output[6] == 50 then
      reading = reading* 10.0
    end
  when 51
    mode = "HOLD"
  else
    mode = "#{output[7]} mode unknown"
  end

  case output[9]
  when 0
    if output[10] == 4 then
      reading = reading/10.0
      unitPre = "n"
    else
      unitPre = ""
    end
  when 2
    #hz duty cycle %
    unitPre = "duty"
  when 4
    unitPre = "diode"
  when 8
    unitPre = ""
  when 16
    unitPre = "M"
  when 32
    unitPre = "K"
  when 64
    unitPre = "m"
    if output[10] == 128 then
      reading /= 10.0
    end
  when 128
    unitPre = "u"
  else
    unitPre = "-#{output[9]} prefix unknown- "
  end

  case output[10]
  when 0
    unitType = "%"
  when 1
    unitType = "F"
  when 2
    unitType = "C"
  when 4
    unitType = "F"
  when 8
    unitType = "HZ"
  when 16
    unitType = "hFE"
  when 32
    unitType = "Ohm"
  when 64
    unitType = "A"
  when 128
    unitType = "V"
  else
    unitType = "-#{output[10]} unit unknown- "
  end

  bars = output[11]
  puts ("%s%5.4g %s%s %s %s %s" % [ output[0].chr, reading, unitPre, unitType, mode, maxmin, "|" * bars])
end

