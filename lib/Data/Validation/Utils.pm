# @(#)$Id$

package Data::Validation::Utils;

use strict;
use namespace::autoclean;
use version; our $VERSION = qv( sprintf '0.9.%d', q$Rev$ =~ /\d+/gmx );

use Moose::Role;
use Moose::Util::TypeConstraints;
use English      qw(-no_match_vars);
use Scalar::Util qw(blessed);
use Class::MOP;
use Try::Tiny;

subtype 'Data::Validation::Exception' => as 'ClassName' =>
   where { $_->can( q(throw) ) };

has 'exception' => is => 'ro', isa => 'Data::Validation::Exception',
   required     => 1;

has 'method'    => is => 'ro', isa => 'Str', required => 1;

has 'pattern'   => is => 'rw', isa => 'Str';

sub _load_class {
   my ($self, $prefix, $class) = @_;

   $class =~ s{ \A $prefix }{}mx;

   if ($class =~ m{ \A \+ }mx) { $class =~ s{ \A \+ }{}mx }
   else { $class = blessed( $self ).q(::).(ucfirst $class) }

   $self->_ensure_class_loaded( $class );

   return bless $self, $class;
}

sub _ensure_class_loaded {
   my ($self, $class, $opts) = @_; $opts ||= {};

   my $package_defined = sub { Class::MOP::is_class_loaded( $class ) };

   not $opts->{ignore_loaded} and $package_defined->() and return 1;

   try   { Class::MOP::load_class( $class ) }
   catch { $self->exception->throw( $_ ) };

   $package_defined->() and return 1;

   my $e = 'Class [_1] loaded but package undefined';

   $self->exception->throw( error => $e, args => [ $class ] );
   return;
}

no Moose::Role;
no Moose::Util::TypeConstraints;

1;

__END__

=pod

=head1 Name

Data::Validation::Utils - Code and attribute reuse

=head1 Version

0.9.$Revision$

=head1 Synopsis

   use Moose;

   with 'Data::Validation::Utils';

=head1 Description

Defines some methods and attributes common to
L<Data::Validation::Constraints> and L<Data::Validation::Filters>

=head1 Configuration and Environment

Defines the following attributes:

=over 3

=item exception

Class capable of throwing an exception

=item method

Name of the constraint to apply

=item pattern

Used by L</isMathchingRegex> as the pattern to match the supplied value
against. This is set by some of the builtin validation methods that
then call L</isMathchingRegex> to perform the actual validation

=back

=head1 Subroutines/Methods

=head2 _load_class

Load the external plugin subclass at run time and rebless self to that class

=head2 _ensure_class_loaded

Throws if class cannot be loaded

=head1 Diagnostics

None

=head1 Dependencies

=over 3

=item L<Class::MOP>

=item L<Moose::Role>

=item L<Moose::Util::TypeConstraints>

=back

=head1 Incompatibilities

There are no known incompatibilities in this module

=head1 Bugs and Limitations

There are no known bugs in this module.
Please report problems to the address below.
Patches are welcome

=head1 Author

Peter Flanigan, C<< <Support at RoxSoft.co.uk> >>

=head1 License and Copyright

Copyright (c) 2013 Peter Flanigan. All rights reserved

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
