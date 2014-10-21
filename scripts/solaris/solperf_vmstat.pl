#!/usr/bin/env perl
BEGIN {
  use Time::Piece;
}
$line = $_;
chomp($line);
if ($line =~ /VMSTAT_INTERVAL = (\d+)$/) {
  $interval=$1;
} elsif ($line =~ /^(\w+), (\w+) (\d+), (\d+) (\d+:\d+:\d+) (\w+) \w+$/) {
  $tz = $2;
  $time = Time::Piece->strptime("$1 $2 $3 $4 $5 $6", "%a %b %d %Y %r");
  $first = 0;
  if (!$hasTime) {
    $hasTime = 1;
    print "Time ($tz),CPU,Runqueue,Blocked,MemoryFree,ContextSwitches,Wait\n";
  }
} elsif ($hasTime && $line =~ /^\s*(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s*$/) {
  # Ignore first one. See Solaris chapter in WAS Performance Cookbook
  if ($first) {
    $time = $time + $interval;
    print $time->strftime("%Y-%m-%d %H:%M:%S") . "," . (100 - $22) . ",$1,$2,$5,$19,$3\n";
  } else {
    $first = true;
  }
}
