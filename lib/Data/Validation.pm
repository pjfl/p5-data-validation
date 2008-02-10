package Data::Validation;

# @(#)$Id$

use strict;
use warnings;
use charnames      qw(:full);
use base           qw(Class::Accessor::Fast);
use English        qw(-no_match_vars);
use Regexp::Common qw(number);
use Scalar::Util   qw(looks_like_number);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

# Class methods

sub check_field {
   # Validate form field values
   my ($me, $e, $stash, $id, $val) = @_;
   my ($fld, $fld_copy, $fld_name, $key, $method, $methods, $ref, @tmp);

   unless (($fld = $stash->{fields}->{ $id }) && $fld->{validate}) {
      $e->throw( error => q(eNoCheckfield), arg1 => $id, arg2 => $val );
   }

   $fld_copy = { %{ $fld } };
   $methods  = $fld->{validate};
   $methods  = [ $fld->{validate} ] if (ref $methods ne q(ARRAY));

   for $method (@{ $methods }) {
      $fld_copy->{validate} = $method;

      unless ($ref = $me->new( $fld_copy )) {
         $e->throw( error => q(eBadValidation), arg1 => $id );
      }

      unless ($ref->validate( $val )) {
         ($key = $method) =~ s{ \A is }{}imx;

         if ((index $id, q(.)) < 0) {
            @tmp = split m{ _ }mx, $id; $fld_name = pop @tmp;
         }
         else { (undef, $fld_name) = split m{ \. }mx, $id }

         $e->throw( error => q(e).$key, arg1 => $fld_name, arg2 => $val );
      }
   }

   return;
}

sub check_form {
   # Validate all the fields on a form by repeated calling check_field
   my ($me, $e, $stash, $flds) = @_; my ($id, $ref);

   for (keys %{ $flds }) {
      $id = $stash->{subr}.q(_).$_;

      next unless (($ref = $stash->{fields}->{ $id }) && $ref->{validate});

      $me->check_field( $e, $stash, $id, $flds->{ $_ } );
   }

   return;
}

sub new {
   my ($me, $args) = @_; my ($class, $file, $self);

   unless ($args->{validate}) { _carp( 'No validation method' ); return }

   $self = { max_length => $args->{max_length},
             max_value  => $args->{max_value },
             method     => $args->{validate  },
             min_length => $args->{min_length},
             min_value  => $args->{min_value },
             null       => $args->{required  } ? 0 : 1,
             pattern    => $args->{pattern   },
             value      => $args->{value     } };

   if ($me->_will( $self->{method} )) {
      $class = ref $me || $me;
      bless $self, $class;
   }
   else {
      ($file = $self->{method}) =~ s{ \A isValid }{}mx;
      $class = __PACKAGE__.q(::).(ucfirst $file);
      eval "require $class";

      if ($EVAL_ERROR) { _carp( $EVAL_ERROR ); return }

      bless $self, $class;
      $self = $self->_init( $args );
   }

   $class->mk_accessors( keys %{ $self } );

   return $self;
}

# Object methods

sub validate {
   my ($me, $val) = @_; my $method = $me->method;

   return 0                    unless ($val || $me->null);
   return 1                    if     ($me->null && !$val);
   return $me->$method( $val ) if     ($me->_will( $method ));
   return $me->_validate( $val );
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

   $me->pattern( $RE{num}{hex} );

   return $me->isMatchingRegex( $val );
}

sub isMandatory { shift; return ((shift) ? 1 : 0) }

sub isMatchingRegex {
   my ($me, $val) = @_;
   my $pat        = $me->pattern;

   return $val    =~ m{ $pat }msx ? 1 : 0;
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

   $me->pattern( $RE{num}{int}{-sep=>'[_]?'} );

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

   return 1 if (defined looks_like_number( $val ));
   return 0;
}

# Private methods

sub _carp { require Carp; goto &Carp::carp }

sub _classfile {
   my ($me, $class) = @_; $class =~ s{ :: }{/}gmx; return $class.q(.pm);
}

sub _croak { require Carp; goto &Carp::croak }

sub _init { return shift }

sub _validate { return _croak( 'Should have been overridden' ) }

sub _will {
   my ($me, $method) = @_; my $class = ref $me || $me;

   return $method ? defined &{ $class.q(::).$method } : 0;
}

1;

__END__

=pod

=head1 Name

Data::Validation - Check data values form conformance with constraints

=head1 Version

0.1.$Revision$

=head1 Synopsis

   use Data::Validation;

=head1 Description

=head1 Subroutines/Methods

=head1 Diagnostics

=head1 Configuration and Environment

=head1 Dependencies

=over 4

=item L<Class::Accessor::Fast>

=item L<Regexp::Common>

=item L<Scalar::Util>

=back

=head1 Incompatibilities

There are no known incompatibilities in this module.

=head1 Bugs and Limitations

There are no known bugs in this module.
Please report problems to the address below.
Patches are welcome.

=head1 Author

Peter Flanigan, C<< <Support at RoxSoft.co.uk> >>

=head1 License and Copyright

Copyright (c) 2007 RoxSoft Limited. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See L<perlartistic>.

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

# Local Variables:
# mode: perl
# tab-width: 3
# End:
