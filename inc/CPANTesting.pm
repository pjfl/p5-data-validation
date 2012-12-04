# @(#)$Id$
# Bob-Version: 1.7

package CPANTesting;

use strict;
use warnings;

use Sys::Hostname; my $host = lc hostname; my $osname = lc $^O;

# Is this an attempted install on a CPAN testing platform?
sub is_testing { !! ($ENV{AUTOMATED_TESTING} || $ENV{PERL_CR_SMOKER_CURRENT}
                 || ($ENV{PERL5OPT} || q()) =~ m{ CPAN-Reporter }mx) }

sub should_abort {
   return 0;
}

sub test_exceptions {
   my $p = shift; is_testing() or return 0;

   $p->{stop_tests} and return 'CPAN Testing stopped in Build.PL';

   $osname eq q(mirbsd)  and return 'Mirbsd  OS unsupported';
   $osname eq q(linux)   and $host =~ m{ k83 }msx
      and return "Stopped andk ${osname} ${host} - ValidHostname";
   $osname eq q(linux)   and $host =~ m{ grosics }msx
      and return "Stopped grahmac ${osname} ${host} - ValidHostname";
   $osname eq q(openbsd) and $host =~ m{ minimunch }msx
      and return "Stopped jlavallee ${osname} ${host} - ValidHostname";
   $osname eq q(linux)   and $host =~ m{ linux-siva }msx
      and return "Stopped Kimmel ${osname} ${host} - ValidHostname";
   return 0;
}

1;

__END__
