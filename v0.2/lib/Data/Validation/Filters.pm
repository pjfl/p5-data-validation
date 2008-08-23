package Data::Validation::Filters;

# @(#)$Id$

use Moose;

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

has 'exception'   => ( is => q(ro), isa => q(ClassName), required => 1 );

sub create_filter {
   my ($me, $config) = @_;
   my $class         = ref $me || $me;
   my $self          = { exception => $me->exception,
                         method    => undef,
                         pattern   => undef,
                         replace   => undef };
   my $method;

   unless ($method = $config->{method}) {
      $me->exception->throw( q(eNoFilterMethod) );
   }

   unless ($me->_will( $method )) {
      $method =~ s{ \A filter }{}mx;
      $class  = __PACKAGE__.q(::).(ucfirst $method);
      ## no critic
      eval "require $class;";
      ## critic

      if ($EVAL_ERROR) { $me->exception->throw( $EVAL_ERROR ) }
   }

   bless $self, $class;

   return $self->_init( $config );
}

sub filter {
   my ($me, $val) = @_; my $method = $me->method;

   return unless (defined $val);
   return $me->$method( $val ) if ($me->_will( $method ));
   return $me->_filter( $val );
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
