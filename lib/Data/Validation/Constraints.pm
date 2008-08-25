package Data::Validation::Constraints;

# @(#)$Id$

use Moose;
use charnames      qw(:full);
use Regexp::Common qw(number);
use Scalar::Util   qw(looks_like_number);

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

with 'Data::Validation::Utils';

has 'max_length' => ( is => q(rw), isa => q(Int) );
has 'max_value'  => ( is => q(rw), isa => q(Int) );
has 'min_length' => ( is => q(rw), isa => q(Int) );
has 'min_value'  => ( is => q(rw), isa => q(Int) );
has 'required'   => ( is => q(rw), isa => q(Bool) );
has 'value'      => ( is => q(rw), isa => q(Any) );

sub validate {
   my ($me, $val) = @_; my $method = $me->method; my $class;

   return 0 if (!$val && $me->required);
   return 1 if (!$val && !$me->required && $method ne q(isMandatory));
   return $me->$method( $val ) if ($me->_will( $method ));

   my $plugin = $me->_load_class( q(isValid), $method );

   return $plugin->_validate( $val );
}

# Private methods

sub _validate {
   shift->exception->throw( q(eNoConstraintOverride) ); return;
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
   return 1 if     (looks_like_number( $val ));
   return 0;
}

1;

__END__

=pod

=head1 Name

Data::Validation::Constraints - Test data values for conformance with constraints

=head1 Version

0.2.$Revision$

=head1 Synopsis

   use Data::Validation::Constraints;

   %config = ( method => $method,
               exception => q(Exception::Class),
               %{ $me->constraints->{ $id } || {} } );

   $constraint_ref = Data::Validation::Constraints->new( %config );

   $constraint_ref->validate( $value );

=head1 Description

Tests a single data value for conformance with a constraint

=head1 Configuration and Environment

=over 3

=item exception

Class capable of throwing an exception

=item method

Name of the constraint to apply

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

=item value

Used by the L</isEqualTo> method as the other value in the comparison

=back

=head1 Subroutines/Methods

=head2 validate

Called by L<Data::Validation>::check_field this method implements
tests for a null input value so that individual validation methods
don't have to. It calls either a built in validation method or
L</_validate> which should have been overridden in a factory
subclass. An exception is thrown if the data value is not acceptable

=head2 _load_class

Load the external constraint subclass at run time

=head2 _validate

Should have been overridden in an external constraint subclass

=head2 _will

Tests to see if the given method is a defined subroutine

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
C<< $me->min_length >> and less than C<< $me->max_length >>

=head2 isValidNumber

Return true if the supplied value C<looks_like_number>

=head1 External Constraints

Each of these constraint subclasses implements the required C<_validate>
method

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

=item L<Moose>

=item L<charnames>

=item L<Class::MOP>

=item L<Regexp::Common>

=item L<Scalar::Util>

=back

=head1 Incompatibilities

There are no known incompatibilities in this module

=head1 Bugs and Limitations

There is no POD coverage test because the subclases docs are in here instead

The L<Data::Validation::Constraints::Date> module requires the as yet
unpublished module L<CatalystX::Usul::Class::Time> and this is not
listed as prerequisite as it would create a circular dependency

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
