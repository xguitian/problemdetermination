# sed -n "s/.*\[\([0-9]\+\).\([a-zA-Z]\+\).\([0-9]\+\):\([^ ]\+\)\(.*\) \([0-9]\+\)$/\2:\1:\3:\4,\6/p" access.log | R --silent --no-save -f httpchannel.r
require(xts, warn.conflicts=FALSE)
require(xtsExtra, warn.conflicts=FALSE)
require(zoo, warn.conflicts=FALSE)
require(txtplot, warn.conflicts=FALSE)

pngfile = "output.png"
pngwidth = 600
asciiwidth = 120
options(scipen=999)

timefunc = function(x, format) { as.POSIXct(paste(as.Date(substr(as.character(x),1,11), format="%b:%d:%Y"), substr(as.character(x),13,20), sep=" "), format=format, tz="UTC") }
data = as.xts(read.zoo(file="stdin", format = "%Y-%m-%d %H:%M:%S", header=TRUE, sep=",", FUN = timefunc))
x = sapply(index(data), function(time) {as.numeric(strftime(time, format = "%H%M"))})
data[,1] = sapply(data[,1], function(point) {point/1000})
txtplot(x, data[,1], width=asciiwidth, xlab="Time", ylab="Response (ms)")
png(pngfile, width=pngwidth)
plot.xts(data, main="HTTP Channel Response Times (ms)", minor.ticks=FALSE, yax.loc="left", auto.grid=TRUE, ylim="fixed")
