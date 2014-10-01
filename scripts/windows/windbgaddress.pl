#!/usr/bin/perl

use strict;
use warnings;
use bigint qw/hex/;

my $argc = $#ARGV + 1;
if ($argc == 0) {
  print "Usage: windbgaddress.pl [!address.txt]+\n";
  exit;
}

my $bar = 4294967296;
my $stackfragdiffmax = 2000000;

sub processHex {
  my ($str) = @_;
  $str =~ s/`//g;
  return hex($str);
}

sub getPrintable {
  my ($x) = @_;
  return $x->as_hex() . " (" . $x->as_int() . ")";
}

foreach my $i (0 .. $#ARGV) {
  my $file = $ARGV[$i];
  open(my $filehandle, $file) || die "Can't open $file: $!";
  my $total = Math::BigInt->bzero();
  my $max = Math::BigInt->bzero();
  my $min = $bar->copy();
  my $laststack = 0;
  my $lastend = Math::BigInt->bzero();
  my $threads = Math::BigInt->bzero();
  my $threadsoverhead = Math::BigInt->bzero();
  my $threadscount = 0;
  while(my $line = <$filehandle>) {
    if ($line =~ /\*\s+([\da-fA-F`]+)\s+([\da-fA-F`]+)\s+([\da-fA-F`]+)\s+(.*)$/) {
      my $baseaddr = $1;
      my $endaddrplusone = $2;
      my $regionsize = $3;
      my $usage = $4;

      $baseaddr = processHex($baseaddr);
      $endaddrplusone = processHex($endaddrplusone);
      $regionsize = processHex($regionsize);
      $usage =~ s/^\s+|\s+$//g;

      if ($baseaddr->bcmp($bar) < 0) {
        $total->badd($regionsize);
        if ($baseaddr->bcmp($max) > 0) {
          $max = $baseaddr->copy();
        }
        if ($baseaddr->bcmp($min) < 0) {
          $min = $baseaddr->copy();
        }
        if ($usage =~ /Stack /) {

          $threads->badd($regionsize);
          $threadscount++;

          # If the last address was a stack, then check if there's fragmentation
          if ($laststack == 1) {
            my $laststackdiff = $baseaddr->bsub($lastend);
            if ($laststackdiff->bcmp($stackfragdiffmax) < 0) {
              $threads->badd($laststackdiff);
              $total->badd($laststackdiff);
              $threadsoverhead->badd($laststackdiff);
            }
          }

          $laststack = 1;
          $lastend = $endaddrplusone->copy();
        } else {
          $laststack = 0;
        }
      } else {
        $laststack = 0;
      }
    }
  }
  print "Total under " . getPrintable($bar) . ": " . getPrintable($total) . "\n";
  print "Min under " . getPrintable($bar) . ": " . getPrintable($min) . "\n";
  print "Max under " . getPrintable($bar) . ": " . getPrintable($max) . "\n";
  print $threadscount . " Threads under " . getPrintable($bar) . ": " . getPrintable($threads) . " (overhead: " . getPrintable($threadsoverhead) . ")\n";
  close($filehandle);
}
