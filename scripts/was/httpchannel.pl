#!/usr/bin/env perl
BEGIN {
  use Time::Piece;
}
$line = $_;
chomp($line);
if ($line =~ /(\S+) (\S+) (\S+) \[(\d+)\/([^\/]+)\/(\d+):(\d+:\d+:\d+) ([\d\-]+)\] "([^"]+)" (\S+) (\S+) (\S+)/) {
  $tz = $8;
  $time = Time::Piece->strptime("$6-$5-$4 $7", "%Y-%b-%d %H:%M:%S");
  if (!$first) {
    $first = true;
    print "Time ($tz),ResponseTime (ms)\n";
  }
  print $time->strftime("%Y-%m-%d %H:%M:%S") . "," . ($12 / 1000) . "\n";
}
