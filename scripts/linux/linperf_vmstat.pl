#!/usr/bin/env perl
BEGIN {
  use Time::Piece;
  print "Time,CPU,Runqueue,Blocked,MemoryFree,PageIns,ContextSwitches,Wait,Steal\n";
}
$line = $_;
chomp($line);
if ($line =~ /VMSTAT_INTERVAL = (\d+)$/) {
  $interval=$1;
} elsif ($line =~ /^\w+ \w+ \d+ \d+:\d+:\d+ \w+ \d+$/) {
  $line =~ s/^(.*) \S+( \d+)$/\1\2/;
  $time = Time::Piece->strptime($line, "%a %b %e %H:%M:%S %Y");
} elsif ($line =~ /^\s*(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/) {
  if ($first) {
    $time = $time + $interval;
    print $time->strftime("%Y-%m-%d %H:%M:%S") . "," . (100 - $15) . ",$1,$2," . ($4 + $5 + $6) . ",$7,$12,$16,$17\n";
  } else {
    $first = true;
  }
}
