# @(#)Ident: CPANTesting.pm 2013-08-08 17:04 pjf ;

package CPANTesting;

use strict;
use warnings;

use Sys::Hostname; my $host = lc hostname; my $osname = lc $^O;

# Is this an attempted install on a CPAN testing platform?
sub is_testing { !! ($ENV{AUTOMATED_TESTING} || $ENV{PERL_CR_SMOKER_CURRENT}
                 || ($ENV{PERL5OPT} || q()) =~ m{ CPAN-Reporter }mx) }

sub should_abort { # Only if the smoker cannot run the toolchain
   is_testing() or return 0;

   $host eq 'xphvmfred' and return
      "ABORT: ${host} - cc06993e-a5e9-11e2-83b7-87183f85d660";
   $osname eq 'cygwin'  and return
      "ABORT: ${host} - 099f04b9-6c8d-1014-9814-a1ae5cf4dae8";
   return 0;
}

sub test_exceptions {
   my $p = shift; my $perl_ver = $p->{_min_perl_ver} || $p->{requires}->{perl};

   is_testing()        or  return 0;
   $] < $perl_ver      and return "TESTS: Perl minimum ${perl_ver}";
   $p->{stop_tests}    and return 'TESTS: CPAN Testing stopped in Build.PL';
   $osname eq 'mirbsd' and return 'TESTS: Mirbsd OS unsupported';
#  $host   eq 'broken' and return "tests: <CPAN Testing uuid>";
   return 0;
}

1;

__END__
