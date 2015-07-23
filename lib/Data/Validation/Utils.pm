package Data::Validation::Utils;

use strict;
use warnings;
use parent 'Exporter::Tiny';

use Data::Validation::Constants qw( EXCEPTION_CLASS TRUE );
use Module::Runtime             qw( require_module );
use Scalar::Util                qw( blessed );
use Try::Tiny;
use Unexpected::Functions       qw( is_class_loaded );

our @EXPORT_OK = qw( ensure_class_loaded load_class throw );

sub ensure_class_loaded ($;$) {
   my ($class, $opts) = @_; $opts //= {};

   not $opts->{ignore_loaded} and is_class_loaded( $class ) and return TRUE;

   try { require_module( $class ) } catch { throw( $_ ) };

   is_class_loaded( $class )
      or throw( 'Class [_1] loaded but package undefined', [ $class ] );

   return TRUE;
}

sub load_class ($$$;$) {
   my ($proto, $prefix, $class, $opts) = @_; $class =~ s{ \A $prefix }{}mx;

   if ($class =~ m{ \A \+ }mx) { $class =~ s{ \A \+ }{}mx }
   else { $class = (blessed $proto || $proto).'::'.(ucfirst $class) }

   ensure_class_loaded $class, $opts;

   return $class;
}

sub throw (;@) {
   EXCEPTION_CLASS->throw( @_ );
}

1;

__END__

=pod

=encoding utf-8

=head1 Name

Data::Validation::Utils - Utility methods for constraints and filters

=head1 Synopsis

   use Data::Validation::Utils qw( ensure_class_loaded );

=head1 Description

Defines some functions L<Data::Validation::Constraints> and
L<Data::Validation::Filters>

=head1 Configuration and Environment

Defines no attributes

=head1 Subroutines/Methods

=head2 ensure_class_loaded

Throws if class cannot be loaded

=head2 load_class

Load the external plugin subclass at run time

=head2 throw

Throws an exception of class
L<EXCEPTION_CLASS|Data::Validation::Constants/EXCEPTION_CLASS>

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
