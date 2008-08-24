package Data::Validation::Filters;

# @(#)$Id$

use Moose;
use Class::MOP;
use English qw(-no_match_vars);

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

has 'exception' => ( is => q(ro), isa => q(ClassName), required => 1 );
has 'method'    => ( is => q(ro), isa => q(Str), required => 1 );
has 'pattern'   => ( is => q(rw), isa => q(Str) );
has 'replace'   => ( is => q(rw), isa => q(Str) );

sub filter {
   my ($me, $val) = @_; my $method = $me->method; my $class;

   return unless (defined $val);
   return $me->$method( $val ) if ($me->_will( $method ));

   ($class = $method) =~ s{ \A filter }{}mx;
   $class = __PACKAGE__.q(::).(ucfirst $class);
   eval { Class::MOP::load_class( $class ) };

   $me->exception->throw( $EVAL_ERROR ) if ($EVAL_ERROR);

   my $self = bless $me, $class;

   return $self->_filter( $val );
}

# Private methods

sub _will {
   my ($me, $method) = @_; my $class = $me->blessed;

   return $method ? defined &{ $class.q(::).$method } : 0;
}

sub _filter { shift->exception->throw( q(eNoFilterOverride) ) }

# Builtin factory filter methods

sub filterEscapeHTML {
   my ($me, $val) = @_;

   $val =~ s{ &(?!(amp|lt|gt|quot);) }{&amp;}gmx;
   $val =~ s{ < }{&lt;}gmx;
   $val =~ s{ > }{&gt;}gmx;
   $val =~ s{ \" }{&quot;}gmx;
   return $val;
}

sub filterLowerCase {
   my ($me, $val) = @_; return lc $val;
}

sub filterNonNumeric {
   my ($me, $val) = @_;

   $val =~ s{ \D+ }{}gmx;
   return $val;
}

sub filterReplaceRegex {
   my ($me, $val) = @_; my ($pattern, $replace);

   return $val unless ($pattern = $me->pattern);

   $replace = $me->replace || q();
   $val =~ s{ $pattern }{$replace}gmx;
   return $val;
}

sub filterTrimBoth {
   my ($me, $val) = @_;

   $val =~ s{ \A \s+ }{}mx; $val =~ s{ \s+ \z }{}mx;
   return $val;
}

sub filterUpperCase {
   my ($me, $val) = @_; return uc $val;
}

sub filterWhiteSpace {
   my ($me, $val) = @_;

   $val =~ s{ \s+ }{}gmx;
   return $val;
}

1;
