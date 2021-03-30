local ffi = require("ffi")

local int = ffi.typeof("int")

do --- unportable-test1
local inp = {
  0, 0.5, -0.5, 1.5, -1.5, 1, -1, 2, -2, 37, -37, false,
  int(0), int(1), int(-1), int(2), int(-2), int(37), int(-37), false,
  0ll, 1ll, -1ll, 2ll, -2ll, 37ll, -37ll, false,
  0ull, 1ull, -1ull, 2ull, -2ull, 37ull, -37ull,
}

local function cksum(s, r)
  local z = 0
  for i=1,#s do z = (z + string.byte(s, i)*i) % 2147483629 end
  if z ~= r then
    error("test failed (got "..z..", expected "..r..") for:\n"..s, 3)
  end
end

local function tostr(n)
  if type(n) == "cdata" then return tostring(n)
  elseif n ~= n then return "nan"
  else return string.format("%+1.5g", n) end
end

local function check(f, expected, y)
  local inp = inp
  local out = {}
  for i=1,#inp do
    if inp[i] then out[i] = tostr(f(inp[i], y)) else out[i] = "\n" end
  end
  local got = string.gsub(table.concat(out, " ").."\n", "\n ", "\n")
  cksum(got, expected)
end

jit.off(check)

local function check2(f, exparray)
  local k = 1
  local raw_arch_name = io.popen('uname -m','r'):read('*l')
  for j=1,#inp do
    local y = inp[j]
    if y then
      if raw_arch_name ~= "ppc64le"  then check(f, exparray[k], y) end
      k = k + 1
    end
  end
end
local raw_arch_name = io.popen('uname -m','r'):read('*l')
if raw_arch_name == "ppc64le"
then
  check(function(x) return -x end, 1174526)
else
  check(function(x) return -x end, 1174528)
end
check2(function(x, y) return x+y end,
{1171039,1239261,1239303,1011706,1490711,949996,1415869,756412,1682910,768883,2201023,1265370,1015700,1556902,807607,1862947,814710,2423097,1265370,1015700,1556902,807607,1862947,814710,2423097,4833809,2909723,7784653,1736671,10743770,1126700,13324037,})

check2(function(x, y) return x-y end,
{1171039,1239303,1239261,1490711,1011706,1415869,949996,1682910,756412,2201023,768883,1265370,1556902,1015700,1862947,807607,2423097,814710,1265370,1556902,1015700,1862947,807607,2423097,814710,4833809,7784653,2909723,10743770,1736671,13324037,1126700,})

check2(function(x, y) return x*y end,
{470107,637182,637132,1308150,1311627,1171039,1174528,1083877,1087553,1561321,1564869,564568,1265370,1269122,1265037,1268973,1643392,1647266,564568,1265370,1269122,1265037,1268973,1643392,1647266,827768,4833809,4847593,4823713,4838210,5230281,5244035,})

check2(function(x, y) return x/y end,
{7946210,7360895,7360865,1580465,927251,1171039,622069,1252901,704706,1542087,960011,14749620,1265370,695208,1188639,661058,1049280,587329,14749620,1265370,695208,1188639,661058,1049280,587329,15042810,4833809,828129,4559889,828509,4208862,828929,})


check2(function(x, y) return x%y end,
{7653740,7304160,7304160,527871,851988,527061,850910,556674,717022,610671,613599,14749620,564568,894526,618652,785052,641760,644574,14749620,564568,894526,618652,785052,641760,644574,15042810,827768,2913108,829285,1737261,951059,959905,})

check2(function(x, y) return x^y end,
{471871,702627,720692,1385612,1803393,1171039,1772007,763817,1583994,4486762,2380423,566647,1265370,2319256,770581,1990479,4566660,2319835,566647,1265370,2319256,770581,1990479,4566660,2319835,830322,4833809,4644705,1071753,2822313,7709069,4647021,})
end
