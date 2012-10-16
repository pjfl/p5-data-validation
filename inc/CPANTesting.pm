# @(#)$Id$

package CPANTesting;

use strict;
use warnings;

use Sys::Hostname;

my $osname = lc $^O; my $host = lc hostname;

sub should_abort {
   return 0;
}

sub test_exceptions {
   my $p = shift; __is_testing() or return 0;

   $p->{stop_tests} and return 'CPAN Testing stopped in Build.PL';

   $osname eq q(mirbsd) and return 'Mirbsd OS unsupported';
   $osname eq q(linux)  and ($ENV{PATH} || q()) =~ m{ \A /home/sand/bin }msx
                        and return 'Stopped andk linux - broken resolver';
   return 0;
}

# Private functions

sub __is_testing { !! ($ENV{AUTOMATED_TESTING} || $ENV{PERL_CR_SMOKER_CURRENT}
                   || ($ENV{PERL5OPT} || q()) =~ m{ CPAN-Reporter }mx) }

1;

__END__
