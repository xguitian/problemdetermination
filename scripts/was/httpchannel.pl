#!/usr/bin/env perl
BEGIN {
  use Time::Piece;
  print "Time,ResponseTime (ms)\n";
}
$line = $_;
chomp($line);
if ($line =~ /(\S+) (\S+) (\S+) \[(\d+)\/([^\/]+)\/(\d+):(\d+:\d+:\d+) ([\d\-]+)\] "([^"]+)" (\S+) (\S+) (\S+)/) {
  $time = Time::Piece->strptime("$6-$5-$4 $7", "%Y-%b-%d %H:%M:%S");
  print $time->strftime("%Y-%m-%d %H:%M:%S") . "," . ($12 / 1000) . "\n";
}
