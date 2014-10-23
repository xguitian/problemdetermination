#!/usr/bin/env perl
BEGIN {
  use Time::Piece;
  eval "use Apache::LogRegex; 1" or die "You must install the Perl Apache::LogRegex module. For example: $ sudo cpan Apache::LogRegex";
  require Apache::LogRegex;
  use List::Util qw(max sum);

  %timeseries = ();

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
    print "Time ($tz),Avg Response ms,Max Response ms,Avg Response bytes,Max Response bytes\n";
  }

  $timeepoch = $time->epoch;

  if ((!defined($min) || (defined($min) && $timeepoch >= $min)) && (!defined($max) || (defined($max) && $timeepoch <= $max))) {
    $responsetime = -1;
    $responsebytes = -1;
    if (defined $data{"%D"}) {
      $responsetime = $data{"%D"} / 1000;
    } elsif (defined $data{"%T"}) {
      $responsetime = $data{"%T"} * 1000;
    }
    if (defined $data{"%b"}) {
      $responsebytes = $data{"%b"};
      if ($responsebytes eq "-") {
        $responsebytes = 0;
      }
    }
    push(@{$timeseries{$time->epoch}{0}}, $responsetime);
    push(@{$timeseries{$time->epoch}{1}}, $responsebytes);
  }
} else {
  die "Could not parse line " . $line . "\n";
}
END {
  $lasttime = undef;
  $size = keys %timeseries;
  if ($size == 0) {
    die "No data points found\n";
  } else {
    foreach my $key (sort keys %timeseries) {
      %val = %{$timeseries{$key}};
      $lasttime = gmtime($key);
      $csv = sum(@{$val{0}})/@{$val{0}} . "," . max(@{$val{0}}) . "," . sum(@{$val{1}})/@{$val{1}} . "," . max(@{$val{1}});
      print $lasttime->strftime("%Y-%m-%d %H:%M:%S") . "," . $csv . "\n";
    }
    if ($size == 1) {
      $lasttime++;
      print $lasttime->strftime("%Y-%m-%d %H:%M:%S") . "," . $csv . "\n";
      $lasttime++;
      print $lasttime->strftime("%Y-%m-%d %H:%M:%S") . "," . $csv . "\n";
    } elsif ($size == 2) {
      $lasttime++;
      print $lasttime->strftime("%Y-%m-%d %H:%M:%S") . "," . $csv . "\n";
    }
  }
}
