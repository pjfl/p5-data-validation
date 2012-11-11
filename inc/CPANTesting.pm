# @(#)$Id$
# Bob-Version: 1.6

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

   $osname eq q(mirbsd) and return 'Mirbsd  OS unsupported';
   $osname eq q(linux)  and $host eq q(k83)
      and return "Stopped andk ${osname} ${host} - broken resolver";
   $osname eq q(linux)  and $host eq q(grosics)
      and return "Stopped grahmac ${osname} ${host} - broken resolver";
   return 0;
}

1;

__END__
