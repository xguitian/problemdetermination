#!/usr/bin/env perl
BEGIN {
  use Time::Piece;
  eval "use Apache::LogRegex; 1" or die "You must install the Perl Apache::LogRegex module. For example: $ sudo cpan Apache::LogRegex";
  require Apache::LogRegex;
  $min = undef;
  $max = undef;
  if (defined $ENV{'MINDATE'}) {
    $t = Time::Piece->strptime($ENV{'MINDATE'}, "%Y-%m-%d %H:%M:%S");
    $min = $t->epoch;
  }
  if (defined $ENV{'MAXDATE'}) {
    $t = Time::Piece->strptime($ENV{'MAXDATE'}, "%Y-%m-%d %H:%M:%S");
    $max = $t->epoch;
  }
  $logformat = $ENV{'LOGFORMAT'};
  if (not defined $logformat) { die "LOGFORMAT envar not specified." };
  $lr = Apache::LogRegex->new($logformat);
  die "Unable to parse log line: $@" if ($@);
}
$line = $_;
chomp($line);
%data = $lr->parse($line);
if (%data) {
  $responsetime = 0;
  $data{"%t"} =~ /\[(\d+)\/([^\/]+)\/(\d+):([^ ]+) ([^\/]+)\]/;
  $tz = $5;
  $time = Time::Piece->strptime("$3-$2-$1 $4", "%Y-%b-%d %H:%M:%S");
  if (!$first) {
    $first = true;
    print "Time ($tz),ResponseTime (ms)\n";
  }

  $timeepoch = $time->epoch;

  if ((!defined($min) || (defined($min) && $timeepoch >= $min)) && (!defined($max) || (defined($max) && $timeepoch <= $max))) {
    if (defined $data{"%D"}) {
      $responsetime = $data{"%D"} / 1000;
    } elsif (defined $data{"%T"}) {
      $responsetime = $data{"%T"} * 1000;
    }
    print $time->strftime("%Y-%m-%d %H:%M:%S") . "," . $responsetime . "\n";
  }
} else {
  die "Could not parse line " . $line . "\n";
}
