package Data::Validation::Filters;

# @(#)$Id$

use Moose;

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

with 'Data::Validation::Utils';

has 'replace' => ( is => q(rw), isa => q(Str) );

sub filter {
   my ($me, $val) = @_; my $method = $me->method; my $class;

   return unless (defined $val);
   return $me->$method( $val ) if ($me->_will( $method ));

   my $plugin = $me->_load_class( q(filter), $method );

   return $plugin->_filter( $val );
}

# Private methods

sub _filter {
   shift->exception->throw( q(eNoFilterOverride) ); return;
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

   $replace = defined $me->replace ? $me->replace : q();
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

__END__

=pod

=head1 Name

<Module::Name> - <One-line description of module's purpose>

=head1 Version

0.2.$Revision$

=head1 Synopsis

   use <Module::Name>;
   # Brief but working code examples

=head1 Description

=head1 Subroutines/Methods

=head2 filter

Calls either a builtin method or an external one

=head2 _filter

=head1 Diagnostics

=head1 Configuration and Environment

=head1 Dependencies

=over 4

=item L<Class::Accessor::Fast>

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
