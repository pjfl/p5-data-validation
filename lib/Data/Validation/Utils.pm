# @(#)$Ident: Utils.pm 2013-07-29 15:52 pjf ;

package Data::Validation::Utils;

use namespace::sweep;
use version; our $VERSION = qv( sprintf '0.14.%d', q$Rev: 1 $ =~ /\d+/gmx );

use Class::Load       qw( is_class_loaded load_class);
use English           qw( -no_match_vars );
use Scalar::Util      qw( blessed );
use Try::Tiny;
use Unexpected::Types qw( Str );
use Moo::Role;

has 'exception' => is => 'ro', isa => sub {
   $_[ 0 ] and $_[ 0 ]->can( 'throw' ) or die 'Exception class cannot throw' },
   required     => 1;

has 'method'    => is => 'ro', isa => Str, required => 1;

has 'pattern'   => is => 'rw', isa => Str;

sub _load_class {
   my ($self, $prefix, $class) = @_; $class =~ s{ \A $prefix }{}mx;

   if ($class =~ m{ \A \+ }mx) { $class =~ s{ \A \+ }{}mx }
   else { $class = blessed( $self ).'::'.(ucfirst $class) }

   $self->_ensure_class_loaded( $class );

   return bless $self, $class;
}

sub _ensure_class_loaded {
   my ($self, $class, $opts) = @_; $opts ||= {};

   my $package_defined = sub { is_class_loaded( $class ) };

   not $opts->{ignore_loaded} and $package_defined->() and return 1;

   try   { load_class( $class ) }
   catch { $self->exception->throw( $_ ) };

   $package_defined->() and return 1;

   my $e = 'Class [_1] loaded but package undefined';

   $self->exception->throw( error => $e, args => [ $class ] );
   return;
}

1;

__END__

=pod

=head1 Name

Data::Validation::Utils - Utility methods

=head1 Version

Describes version v0.14.$Rev: 1 $ of L<Data::Validation::Utils>

=head1 Synopsis

   use Moo;

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

=item L<Class::Load>

=item L<Moo::Role>

=item L<Try::Tiny>

=item L<Unexpected::Types>

=back

=head1 Incompatibilities

There are no known incompatibilities in this module

=head1 Bugs and Limitations

There are no known bugs in this module.
Please report problems to the address below.
Patches are welcome

=head1 Author

Peter Flanigan, C<< <pjfl@cpan.org> >>

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
