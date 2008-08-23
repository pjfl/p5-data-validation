package Data::Validation;

# @(#)$Id$

use strict;
use warnings;
use charnames      qw(:full);
use base           qw(Class::Accessor::Fast);
use English        qw(-no_match_vars);
use File::Spec::Functions;
use NEXT;
use Regexp::Common qw(number);
use Scalar::Util   qw(looks_like_number);

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(constraints exception fields filters
                              max_length max_value method min_length
                              min_value pattern replace required
                              value) );

sub new {
   my ($me, $e, $config) = @_; my $class = ref $me || $me; $config ||= {};

   return bless { exception   => $e,
                  constraints => $config->{constraints} || {},
                  fields      => $config->{fields     } || {},
                  filters     => $config->{filters    } || {} }, $class;
}

sub check_form {
   # Validate all the fields on a form by repeated calling check_field
   my ($me, $prefix, $form) = @_; $prefix ||= q(); my $field;

   unless ($form && ref $form eq q(HASH)) {
      $me->exception->throw( q(eNoFormValues) );
   }

   for my $name (keys %{ $form }) {
      my $id = $prefix.$name;

      next unless ($field = $me->fields->{ $id } and $field->{validate});

      $form->{ $name } = $me->check_field( $id, $form->{ $name } );
   }

   return $form;
}

sub check_field {
   # Validate form field values
   my ($me, $id, $val) = @_;
   my ($config, $constraint_ref, $field, $filter_ref, $key, $method);

   unless ($id and $field = $me->fields->{ $id } and $field->{validate}) {
      $me->exception->throw( error => q(eNoFieldDefinition),
                             arg1  => $id, arg2 => $val );
   }

   if ($field->{filters}) {
      for $method (split q( ), $field->{filters}) {
         $config = { method => $method, %{ $me->filters->{ $id } || {} } };

         unless ($filter_ref = $me->create_filter( $config )) {
            $me->exception->throw( error => q(eBadFilter),
                                   arg1  => $id, arg2 => $method );
         }

         $val = $filter_ref->filter( $val );
      }
   }

   for $method (split q( ), $field->{validate}) {
      $config = { method => $method, %{ $me->constraints->{ $id } || {} } };

      unless ($constraint_ref = $me->create_constraint( $config )) {
         $me->exception->throw( error => q(eBadConstraint),
                                arg1  => $id, arg2 => $method );
      }

      unless ($constraint_ref->validate( $val )) {
         ($key = $method) =~ s{ \A is }{}imx;
         $me->exception->throw( error => q(e).$key,
                                arg1  => $id, arg2 => $val );
      }
   }

   return $val;
}

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

sub create_constraint {
   my ($me, $config) = @_;
   my $class         = ref $me || $me;
   my $self          = { exception  => $me->exception,
                         max_length => undef,
                         max_value  => undef,
                         method     => undef,
                         min_length => undef,
                         min_value  => undef,
                         pattern    => undef,
                         required   => 0,
                         value      => undef };
   my $method;

   unless ($method = $config->{method}) {
      $me->exception->throw( q(eNoConstraintMethod) );
   }

   unless ($me->_will( $method )) {
      $method  =~ s{ \A isValid }{}mx;
      $class   = __PACKAGE__.q(::).(ucfirst $method);
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

sub validate {
   my ($me, $val) = @_; my $method = $me->method;

   return 0 if (!$val && $me->required);
   return 1 if (!$val && !$me->required && $method ne q(isMandatory));
   return $me->$method( $val ) if ($me->_will( $method ));
   return $me->_validate( $val );
}

# Private methods

sub _filter { shift->exception->throw( q(eNoFilterOverride) ) }

sub _init {
   my ($me, $config) = @_;

   for (grep { exists $me->{ $_ } } keys %{ $config }) {
      $me->{ $_ } = $config->{ $_ };
   }

   return $me;
}

sub _validate { shift->exception->throw( q(eNoConstraintOverride) ) }

sub _will {
   my ($me, $method) = @_; my $class = ref $me || $me;

   return $method ? defined &{ $class.q(::).$method } : 0;
}

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

sub isMandatory { shift; return ((shift) ? 1 : 0) }

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

__END__

=pod

=head1 Name

Data::Validation - Check data values for conformance with constraints

=head1 Version

0.2.$Rev$

=head1 Synopsis

   use Data::Validation;

   sub check_form  {
      my ($me, $s, @rest) = @_;

      # Where $me can throw an exception and $s->{fields} contains a
      # field definition for each of the keys in %{ $rest->[0] }
      my $dv = Data::Validation->new( $me, $s->{fields} );

      return $dv->check_form( $s->{subr}.q(_), %{ $rest->[0] } );
   }

   sub check_field {
      my ($me, $id, $value) = @_;

      # Where $me can throw an exception and $s->{fields} contains a
      # field definition for $s->{fields}->{ $id }
      my $dv = Data::Validation->new( $me, $s->{fields} );

      return $dv->check_field( $id, $value );
   }

=head1 Description

This module implements filters and common constraints in builtin
methods and uses a factory pattern to implement an extensible list of
external filters and constraints.

=head1 Configuration and Environment

=head2 new

Simple constructor which expects a class with a C<throw> method and a hash
reference containing the field definitions.

=head1 Subroutines/Methods

=head2 check_form

   my $dv = Data::Validation->new( $exception, $fields );

   $dv->check_form( $prefix, $values );

Calls L</check_field> for each of the keys in the C<$values> hash. In
the calls to L</check_field> the C<$values> key has the C<$prefix>
prepended to form the key to the C<$fields> hash

=head2 check_field

   my $dv = Data::Validation->new( $exception, $fields );

   $dv->check_field( $id, $value );

Checks one value for conformance. The C<$id> is used as a key to the
C<$fields> hash whose I<validate> attribute contains the list of space
separated constraint names. The value is tested against each
constraint in turn. All tests must pass or the subroutine will use the
C<$exception> object to I<throw> an error. Values of the fields hash
are:

=over 3

=item validate

Space separated list of validation method names. Each method must return
true for the value to be accepted

=item filters

Space separated list of filter methods names. Filters are applied to values
before they are tested for validity

=item max_length

Used by L</isValidLength>. The I<length> of the supplied value must be
numerically less than this

=item max_value

Used by L</isBetweenValues>.

=item min_length

Used by L</isValidLength>.

=item min_value

Used by L</isBetweenValues>.

=item required

If true then null values are not allowed regardless of what other
validation would be done

=item pattern

Used by L</isMathchingRegex> as the pattern to match the supplied value
against. This is set by some of the builtin validation methods that
then call L</isMathchingRegex> to perform the actual validation

=item replace

=item value

Used by the L</isEqualTo> method as the other value in the comparison

=back

=head2 filter

Calls either a builtin method or an external one

=head2 validate

Called by L</check_field> this method implements tests for a null
input value so that individual validation methods don't have to. It
calls either a built in validation method or L</_validate> which should
have been overridden in a factory subclass

=head2 isBetweenValues

Test to see if the supplied value is numerically greater than
C<< $me->min_value >> and less than C<< $me->max_value >>

=head2 isEqualTo

Test to see if the supplied value is equal to C<< $me->value >>. Calls
C<isValidNumber> on both values to determine the type of comparison
to perform

=head2 isMandatory

Null values are not allowed

=head2 isMatchingRegex

Does the supplied value match C<< $me->pattern >>?

=head2 isPrintable

Is the supplied value entirely composed of printable characters?

=head2 isSimpleText

Simple text is defined as matching the pattern '\A [a-zA-Z0-9_ \-\.]+ \z'

=head2 isValidHostname

Calls C<gethostbyname> on the supplied value

=head2 isValidIdentifier

Identifiers must match the pattern '\A [a-zA-Z_] \w* \z'

=head2 isValidInteger

Tests to see if the supplied value is an integer

=head2 isValidLength

Tests to see if the length of the supplied value is greater than
C<$me-E<gt>min_length> and less than C<< $me->max_length >>

=head2 isValidNumber

Return true if the supplied value C<looks_like_number>

=head2 _filter

=head2 _init

Must return the self referential object. Allows factory subclasses to
declare their own attributes whilst still having the factory create
accessors and mutators

=head2 _validate

Should have been overridden in a factory subclass

=head2 _will

Tests to see if the given method is a defined subroutine

=head1 External Constraints

Each of these factory subclasses implement the required C<_validate>
method and optionally implements the C<_init> method

=head2 Date

If the C<str2time> method in the L<CatalystX::Usul::Class::Time>
module can parse the supplied value then it is deemed to be a valid
date

=head2 Email

If the C<address> method in the L<Email::Valid> module can parse the
supplied value then it is deemed to be a valid email address

=head2 Password

Currently implements a minimum password length of six characters and
that the password contain at least one non alphabetic character

=head2 Path

Screen out these characters: ; & * { } and space

=head2 Postcode

Tests to see if the supplied value matches one of the approved
patterns for a valid postcode

=head2 URL

Call the C<request> method in L<LWP::UserAgent> to test if a URL is accessible

=head1 Diagnostics

None

=head1 Dependencies

=over 3

=item L<charnames>

=item L<Class::Accessor::Fast>

=item L<Class::Null>

=item L<Email::Valid>

=item L<Exception::Class>

=item L<LWP::UserAgent>

=item L<NEXT>

=item L<Regexp::Common>

=item L<Scalar::Util>

=back

=head1 Incompatibilities

There are no known incompatibilities in this module

=head1 Bugs and Limitations

There is no POD coverage test because the subclases docs are in here instead

The L<Data::Validation::Date> module requires the as yet unpublished module
L<CatalystX::Usul::Class::Time> and this is not listed as pre req as it
would create a circular dependancy

Please report problems to the address below.
Patches are welcome

=head1 Author

Peter Flanigan, C<< <Support at RoxSoft.co.uk> >>

=head1 License and Copyright

Copyright (c) 2008 Peter Flanigan. All rights reserved

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See L<perlartistic>

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE

=cut

# Local Variables:
# mode: perl
# tab-width: 3
# End:
