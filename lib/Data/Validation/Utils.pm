package Data::Validation::Utils;

# @(#)$Id$

use Class::MOP;
use English qw(-no_match_vars);
use Moose::Role;
use Moose::Util::TypeConstraints;

subtype 'Exception' => as 'ClassName' => where { $_->can( q(throw) ) };

sub _load_class {
   my ($me, $prefix, $class) = @_;

   $class =~ s{ \A $prefix }{}mx;

   if ($class =~ m{ \A \+ }mx) { $class =~ s{ \A \+ }{}mx }
   else { $class = $me->blessed.q(::).(ucfirst $class) }

   eval { Class::MOP::load_class( $class ) };

   $me->exception->throw( $EVAL_ERROR ) if ($EVAL_ERROR);

   return bless $me, $class;
}

sub _will {
   my ($me, $method) = @_;

   return $method ? defined &{ $me->blessed.q(::).$method } : 0;
}

1;
