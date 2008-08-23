package Data::Validation::Constraints;

# @(#)$Id$

use Moose;
use charnames      qw(:full);
use English        qw(-no_match_vars);
use Regexp::Common qw(number);
use Scalar::Util   qw(looks_like_number);

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

has 'exception'  => ( is => q(ro), isa => q(ClassName), required => 1 );
has 'max_length' => ( is => q(rw), isa => q(Int) );
has 'max_value'  => ( is => q(rw), isa => q(Int) );
has 'method'     => ( is => q(ro), isa => q(Str), required => 1 );
has 'min_length' => ( is => q(rw), isa => q(Int) );
has 'min_value'  => ( is => q(rw), isa => q(Int) );
has 'pattern'    => ( is => q(rw), isa => q(Str) );
has 'required'   => ( is => q(rw), isa => q(Bool) );
has 'value'      => ( is => q(rw), isa => q(Any) );

sub validate {
   my ($me, $val) = @_; my $method = $me->method;

   return 0 if (!$val && $me->required);
   return 1 if (!$val && !$me->required && $method ne q(isMandatory));
   return $me->$method( $val ) if ($me->_will( $method ));

   $method   =~ s{ \A isValid }{}mx;
   my $class = __PACKAGE__.q(::).(ucfirst $method);
   ## no critic
   eval "require $class;";
   ## critic

   if ($EVAL_ERROR) { $me->exception->throw( $EVAL_ERROR ) }

   my $self = bless $me, $class;

   $self = $self->_init();

   return $self->_validate( $val );
}

# Private methods

sub _init {
   return shift;
}

sub _will {
   my ($me, $method) = @_; my $class = ref $me || $me;

   return $method ? defined &{ $class.q(::).$method } : 0;
}

sub _validate {
   shift->exception->throw( q(eNoConstraintOverride) );
}

# Builtin factory validation methods

sub isBetweenValues {
   my ($me, $val) = @_;

   return 0 if (defined $me->min_value and $val < $me->min_value);
   return 0 if (defined $me->max_value and $val > $me->max_value);
   return 1;
}

sub isEqualTo {
   my ($me, $val) = @_;

   if ($me->isValidNumber( $val ) && $me->isValidNumber( $me->value )) {
      return 1 if ($val == $me->value);
      return 0;
   }

   return 1 if ($val eq $me->value);
   return 0;
}

sub isHexadecimal {
   my ($me, $val) = @_;

   $me->pattern( '\A '.$RE{num}{hex}.' \z' );
   return $me->isMatchingRegex( $val );
}

sub isMandatory {
   shift; return ((shift) ? 1 : 0);
}

sub isMatchingRegex {
   my ($me, $val) = @_; my $pat = $me->pattern;

   return $val =~ m{ $pat }msx ? 1 : 0;
}

sub isPrintable {
   my ($me, $val) = @_;

   $me->pattern( '\A \p{IsPrint}+ \z' );
   return $me->isMatchingRegex( $val );
}

sub isSimpleText {
   my ($me, $val) = @_;

   $me->pattern( '\A [a-zA-Z0-9_ \-\.]+ \z' );
   return $me->isMatchingRegex( $val );
}

sub isValidHostname {
   my ($me, $val) = @_; return (gethostbyname $val)[0] ? 1 : 0;
}

sub isValidIdentifier {
   my ($me, $val) = @_;

   $me->pattern( '\A [a-zA-Z_] \w* \z' );
   return $me->isMatchingRegex( $val );
}

sub isValidInteger {
   my ($me, $val) = @_;

   $me->pattern( '\A '.$RE{num}{int}{-sep=>'[_]?'}.' \z' );

   return 0 unless ($me->isMatchingRegex( $val ));
   return 0 unless (int $val == $val);
   return 1;
}

sub isValidLength {
   my ($me, $val) = @_;

   return 0 if (defined $me->min_length and length $val < $me->min_length);
   return 0 if (defined $me->max_length and length $val > $me->max_length);
   return 1;
}

sub isValidNumber {
   my ($me, $val) = @_;

   return 0 unless (defined $val);
   return 1 if     (defined looks_like_number( $val ));
   return 0;
}

1;
