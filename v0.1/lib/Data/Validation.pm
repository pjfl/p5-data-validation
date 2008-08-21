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

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(exception fields max_length max_value method
                              min_length min_value pattern required
                              value) );

sub new {
   my ($me, $e, $fields) = @_;

   return bless { exception => $e, fields => $fields }, ref $me || $me;
}

sub check_form {
   # Validate all the fields on a form by repeated calling check_field
   my ($me, $prefix, $values) = @_; my $ref; $prefix ||= q();

   unless ($values && ref $values eq q(HASH)) {
      $me->exception->throw( q(eNoValues) );
   }

   for (keys %{ $values }) {
      my $id = $prefix.$_;

      next unless ($ref = $me->fields->{ $id } and $ref->{validate});

      $values->{ $_ } = $me->check_field( $id, $values->{ $_ } );
   }

   return $values;
}

sub check_field {
   # Validate form field values
   my ($me, $id, $val) = @_;
   my ($filter, $filter_ref, $fld, $fld_copy, $key, $method, $val_ref);

   unless ($id and $fld = $me->fields->{ $id } and $fld->{validate}) {
      $me->exception->throw( error => q(eNoCheckfield),
                             arg1  => $id, arg2 => $val );
   }

   $fld_copy = { %{ $fld } };

   if ($fld->{filters}) {
      for $filter (split q( ), $fld->{filters}) {
         $fld_copy->{filter} = $filter;

         unless ($filter_ref = $me->create_filter( $fld_copy )) {
            $me->exception->throw( error => q(eBadFilter),
                                   arg1  => $id, arg2 => $filter );
         }

         $val = $filter_ref->filter( $val );
      }
   }

   for $method (split q( ), $fld->{validate}) {
      $fld_copy->{method} = $method;

      unless ($val_ref = $me->create_validator( $fld_copy )) {
         $me->exception->throw( error => q(eBadValidation), arg1 => $id );
      }

      unless ($val_ref->validate( $val )) {
         ($key = $method) =~ s{ \A is }{}imx;
         $me->exception->throw( error => q(e).$key,
                                arg1  => $id, arg2 => $val );
      }
   }

   return $val;
}

sub create_filter {
}

sub create_validator {
   my ($me, $args) = @_;
   my $class       = ref $me || $me;
   my $self        = { exception  => $me->exception,
                       max_length => undef,
                       max_value  => undef,
                       min_length => undef,
                       min_value  => undef,
                       pattern    => undef,
                       required   => 0,
                       value      => undef };

   unless ($self->{method} = delete $args->{method}) {
      $me->e->throw( 'No validation method' );
   }

   unless ($me->_will( $self->{method} )) {
      (my $method = $self->{method}) =~ s{ \A isValid }{}mx;
      $class   = __PACKAGE__.q(::).(ucfirst $method);
      ## no critic
      eval "require $class;";
      ## critic

      if ($EVAL_ERROR) { $me->exception->throw( $EVAL_ERROR ) }
   }

   bless $self, $class;

   return $self->_init( $args );
}

sub validate {
   my ($me, $val) = @_; my $method = $me->method;

   return 0 if (!$val && $me->required);
   return 1 if (!$val && !$me->required && $method ne q(isMandatory));
   return $me->$method( $val ) if ($me->_will( $method ));
   return $me->_validate( $val );
}

# Private methods

sub _init {
   my ($me, $args) = @_;

   for (grep { exists $me->{ $_ } } keys %{ $args }) {
      $me->{ $_ } = $args->{ $_ };
   }

   return $me;
}

sub _validate { shift->exception->throw( 'Should have been overridden' ) }

sub _will {
   my ($me, $method) = @_; my $class = ref $me || $me;

   return $method ? defined &{ $class.q(::).$method } : 0;
}

# Builtin factory methods

sub isBetweenValues {
   my ($me, $val) = @_;

   return 0 if (defined $me->min_value && $val < $me->min_value);
   return 0 if (defined $me->max_value && $val > $me->max_value);
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

   return 0 if (defined $me->min_length && length $val < $me->min_length);
   return 0 if (defined $me->max_length && length $val > $me->max_length);
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

Data::Validation - Check data values form conformance with constraints

=head1 Version

0.1.$Rev$

=head1 Synopsis

   use Data::Validation;

   sub check_field {
      my ($me, $stash, $id, $val) = @_;

      return Data::Validation->check_field( $me, $stash->{fields}, @id, $val );
   }

   sub check_form  {
      my ($me, $stash, $values) = @_;

      return Data::Validation->check_form( $me,
                                           $stash->{fields},
                                           $stash->{method_name}.q(_),
                                           $values );
   }

=head1 Description

This module implements common constraints in builtin methods and uses a
factory pattern to implement an extensible list of external
constraints.

=head1 Configuration and Environment

The C<$stash-E<gt>{fields}> hash is passed to both C<check_field> and
C<check_form> and is used to instantiate each validation object. The
configuration keys are:

=over 3

=item validate

Space separated list of validation method names. Each method must return
true for the value to be accepted

=item max_length

Used by C<isValidLength>. The C<length> of the supplied value must be
numerically less than this

=item max_value

Used by C<isBetweenValues>.

=item min_length

Used by C<isValidLength>.

=item min_value

Used by C<isBetweenValues>.

=item required

If true then null values are not allowed regardless of what other
validation would be done

=item pattern

Used by C<isMathchingRegex> as the pattern to match the supplied value
against. This is set by some of the builtin validation methods that
then call C<isMathchingRegex> to perform the actual validation

=item value

Used by the C<isEqualTo> method as the other value in the comparison

=back

=head1 Subroutines/Methods

=head2 new

The constructor is called by C<check_field> so you don't have to. If
necessary it C<require>s a factory subclass and calls it's C<_init>
method. Any additional attributes added to C<$self> will have
accessors and mutators created for them

=head2 check_field

   Data::Validation->check_field( $error_ref, $fields, $id, $value );

Checks one value for conformance. The C<$id> is used as a key to the
C<$fields> hash whose validate attribute contains the list of space
separated constraint names. The value is tested against each
constraint in turn. All tests must pass or the subroutine will use the
C<$error_ref> object to C<throw> an error.

=head2 check_form

   Data::Validation->check_form( $error_ref, $fields, $prefix, $values );

Calls C<check_field> for each of the keys in the C<$values> hash. In
the calls to C<check_field> the C<$values> key has the C<$prefix>
prepended to form the key to the C<$fields> hash.

=head2 validate

Called by C<check_field> this method implements tests for a null
input value so that individual validation methods don't have to. It
calls either a built in validation method or C<_validate> which should
have been overridden in a factory subclass

=head2 isBetweenValues

Test to see if the supplied value is numerically greater than
C<$me-E<gt>min_value> and less than C<$me-E<gt>max_value>

=head2 isEqualTo

Test to see if the supplied value is equal to C<$me-E<gt>value>. Calls
C<isValidNumber> on both values to determine the type of comparison
to perform

=head2 isMandatory

Null values are not allowed

=head2 isMatchingRegex

Does the supplied value match C<$me-E<gt>pattern>?

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
C<$me-E<gt>min_length> and less than C<$me-E<gt>max_length>

=head2 isValidNumber

Return true if the supplied value C<looks_like_number>

=head2 _carp

Call C<Carp::carp> but delay loading module

=head2 _croak

Call C<Carp::croak> but delay loading module

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

Carps warnings about unknown or bad validation methods

=head1 Dependencies

=over 3

=item L<charnames>

=item L<Class::Accessor::Fast>

=item L<Class::Null>

=item L<Email::Valid>

=item L<Exception::Class>

=item L<LWP::UserAgent>

=item L<Readonly>

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
