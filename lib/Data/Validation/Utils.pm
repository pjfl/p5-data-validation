package Data::Validation::Utils;

use namespace::autoclean;

use Data::Validation::Constants;
use English               qw( -no_match_vars );
use Module::Runtime       qw( require_module );
use Scalar::Util          qw( blessed );
use Try::Tiny;
use Unexpected::Functions qw( is_class_loaded );
use Unexpected::Types     qw( Str );
use Moo::Role;

has 'method'  => is => 'ro', isa => Str, required => 1;

has 'pattern' => is => 'rw', isa => Str;

# Private methods
my $_ensure_class_loaded = sub {
   my ($self, $class, $opts) = @_; $opts ||= {};

   not $opts->{ignore_loaded} and is_class_loaded( $class ) and return 1;

   try   { require_module( $class ) }
   catch { EXCEPTION_CLASS->throw( $_ ) };

   is_class_loaded( $class ) or EXCEPTION_CLASS->throw
      ( error => 'Class [_1] loaded but package undefined',
        args  => [ $class ] );

   return 1;
};

# Public methods
sub load_class {
   my ($self, $prefix, $class, $opts) = @_; $class =~ s{ \A $prefix }{}mx;

   if ($class =~ m{ \A \+ }mx) { $class =~ s{ \A \+ }{}mx }
   else { $class = blessed( $self ).'::'.(ucfirst $class) }

   $self->$_ensure_class_loaded( $class, $opts );

   return bless $self, $class;
}

1;

__END__

=pod

=encoding utf8

=head1 Name

Data::Validation::Utils - Utility methods for constraints and filters

=head1 Synopsis

   use Moo;

   with 'Data::Validation::Utils';

=head1 Description

Defines some methods and attributes common to
L<Data::Validation::Constraints> and L<Data::Validation::Filters>

=head1 Configuration and Environment

Defines the following attributes:

=over 3

=item C<method>

Name of the constraint to apply. Required

=item C<pattern>

Used by L</isMathchingRegex> as the pattern to match the supplied value
against. This is set by some of the builtin validation methods that
then call L</isMathchingRegex> to perform the actual validation

=back

=head1 Subroutines/Methods

=head2 load_class

Load the external plugin subclass at run time and rebless self to that class

=head2 ensure_class_loaded

Throws if class cannot be loaded

=head1 Diagnostics

None

=head1 Dependencies

=over 3

=item L<Module::Runtime>

=item L<Try::Tiny>

=item L<Unexpected>

=back

=head1 Incompatibilities

There are no known incompatibilities in this module

=head1 Bugs and Limitations

There are no known bugs in this module. Please report problems to
http://rt.cpan.org/NoAuth/Bugs.html?Dist=Data-Validation.  Patches are welcome

=head1 Acknowledgements

Larry Wall - For the Perl programming language

=head1 Author

Peter Flanigan, C<< <pjfl@cpan.org> >>

=head1 License and Copyright

Copyright (c) 2015 Peter Flanigan. All rights reserved

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
