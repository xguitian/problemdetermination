# graphcsv.r: Graph an arbitrary set of time series data with first column of time and other columns integer values
# Use envars as input (see below)
#
# Input of the form:
#  Time,Col1,Col2,Col3...
#  2014-01-01 01:02:03,Col1Value,Col2Value,Col3Value...
#  2014-01-02 01:02:03,Col1Value,Col2Value,Col3Value...
#
# cat input.csv | R --silent --no-save -f timeplot.r

requiredLibraries = c("xts", "xtsExtra", "zoo", "txtplot")
installedLibraries = requiredLibraries[!(requiredLibraries %in% installed.packages()[,"Package"])]
if(length(installedLibraries)) install.packages(requiredLibraries, repos=c("http://cran.us.r-project.org","http://R-Forge.R-project.org"), quiet=TRUE)
library(xts, warn.conflicts=FALSE)
library(xtsExtra, warn.conflicts=FALSE)
library(zoo, warn.conflicts=FALSE)
library(txtplot, warn.conflicts=FALSE)
options(scipen=999)

title = if (nchar(Sys.getenv("INPUT_TITLE")) == 0) "TITLE" else Sys.getenv("INPUT_TITLE")
pngwidth = as.integer(if (nchar(Sys.getenv("INPUT_PNGWIDTH")) == 0) "800" else Sys.getenv("INPUT_PNGWIDTH"))
pngheight = as.integer(if (nchar(Sys.getenv("INPUT_PNGHEIGHT")) == 0) "600" else Sys.getenv("INPUT_PNGHEIGHT"))
cols = as.integer(if (nchar(Sys.getenv("INPUT_COLS")) == 0) "1" else Sys.getenv("INPUT_COLS"))
timezone = if (nchar(Sys.getenv("TZ")) == 0) "UTC" else Sys.getenv("TZ")
Sys.setenv(TZ=timezone)
asciiwidth = as.integer(if (nchar(Sys.getenv("INPUT_ASCIIWIDTH")) == 0) "120" else Sys.getenv("INPUT_ASCIIWIDTH"))
asciicolumn = as.integer(if (nchar(Sys.getenv("INPUT_ASCIICOLUMN")) == 0) "1" else Sys.getenv("INPUT_ASCIICOLUMN"))
pngfile = paste(title, ".png", sep="")
fontsize = as.numeric(if (nchar(Sys.getenv("INPUT_FONTSIZE")) == 0) "1.3" else Sys.getenv("INPUT_FONTSIZE"))

data = as.xts(read.zoo(file="stdin", format = "%Y-%m-%d %H:%M:%S", header=TRUE, sep=",", tz=timezone))
x = sapply(index(data), function(time) {as.numeric(strftime(time, format = "%H%M"))})
txtplot(x, data[,asciicolumn], width=asciiwidth, xlab=paste("Time (", timezone, ")", sep=""), ylab=dimnames(data)[[2]][asciicolumn])
png(pngfile, width=pngwidth, height=pngheight)
# Extend data points to entire x-axis; however, this causes overlap of the two axes: xaxs="i"
plot.xts(
  data,
  main=paste(title, " (", timezone, ")", sep=""),
  minor.ticks=FALSE,
  yax.loc="left",
  auto.grid=TRUE,
  nc=cols,
  cex.lab=fontsize,
  cex.axis=fontsize,
  cex.main=fontsize,
  cex.sub=fontsize
)
