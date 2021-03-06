<div>
    <a href="https://travis-ci.org/pjfl/p5-data-validation"><img src="https://travis-ci.org/pjfl/p5-data-validation.svg?branch=master" alt="Travis CI Badge"></a>
    <a href="https://roxsoft.co.uk/coverage/report/data-validation/latest"><img src="https://roxsoft.co.uk/coverage/badge/data-validation/latest" alt="Coverage Badge"></a>
    <a href="http://badge.fury.io/pl/Data-Validation"><img src="https://badge.fury.io/pl/Data-Validation.svg" alt="CPAN Badge"></a>
    <a href="http://cpants.cpanauthors.org/dist/Data-Validation"><img src="http://cpants.cpanauthors.org/dist/Data-Validation.png" alt="Kwalitee Badge"></a>
</div>

# Name

Data::Validation - Filter and validate data values

# Version

Describes version v0.28.$Rev: 5 $ of [Data::Validation](https://metacpan.org/pod/Data::Validation)

# Synopsis

    use Data::Validation;

    sub check_field {
       my ($self, $config, $id, $value) = @_;

       my $dv_obj = $self->_build_validation_obj( $config );

       return $dv_obj->check_field( $id, $value );
    }

    sub check_form  {
       my ($self, $config, $form) = @_;

       my $dv_obj = $self->_build_validation_obj( $config );
       my $prefix = $config->{form_name}.q(.);

       return $dv_obj->check_form( $prefix, $form );
    }

    sub _build_validation_obj {
       my ($self, $config) = @_;

       return Data::Validation->new( {
          constraints => $config->{constraints} // {},
          fields      => $config->{fields}      // {},
          filters     => $config->{filters}     // {} } );
    }

# Description

This module implements filters and common constraints in builtin
methods and uses a factory pattern to implement an extensible list of
external filters and constraints

Data values are filtered first before testing against the constraints. The
filtered data values are returned if they conform to the constraints,
otherwise an exception is thrown

# Configuration and Environment

Defines the following attributes;

- `constraints`

    Hash containing constraint attributes. Keys are the `id` values passed
    to ["check\_field"](#check_field). See [Data::Validation::Constraints](https://metacpan.org/pod/Data::Validation::Constraints)

- `fields`

    Hash containing field definitions. Keys are the `id` values passed
    to ["check\_field"](#check_field). Each field definition can contain a space
    separated list of filters to apply and a space separated list of
    constraints. Each constraint method must return true for the value to
    be accepted

    The constraint method can also be a list of methods separated by | (pipe)
    characters. This has the effect of requiring only one of the constraints
    to be true

        isMandatory isHexadecimal|isValidNumber

    This constraint would require a value that was either hexadecimal or a
    valid number

- `filters`

    Hash containing filter attributes. Keys are the `id` values passed
    to ["check\_field"](#check_field). See [Data::Validation::Filters](https://metacpan.org/pod/Data::Validation::Filters)

- `level`

    Positive integer defaults to 1. Used to select the stack frame from which
    to throw the `check_field` exception

# Subroutines/Methods

## check\_form

    $form = $dv->check_form( $prefix, $form );

Calls ["check\_field"](#check_field) for each of the keys in the `form` hash. In
the calls to ["check\_field"](#check_field) the `form` keys have the `prefix`
prepended to them to create the key to the `fields` hash

If one of the fields constraint names is `compare`, then the fields
value is compared with the value for another field. The constraint
attribute `other_field` determines which field to compare and the
`operator` constraint attribute gives the comparison operator which
defaults to `eq`

All fields are checked. Multiple error objects are stored, if they occur,
in the `args` attribute of the returned error object

## check\_field

    $value = $dv->check_field( $id, $value );

Checks one value for conformance. The `id` is used as a key to the
`fields` hash whose `validate` attribute contains the list of space
separated constraint names. The value is tested against each
constraint in turn. All tests must pass or the subroutine will use the
`EXCEPTION_CLASS` class to `throw` an error

# Diagnostics

None

# Dependencies

- [Moo](https://metacpan.org/pod/Moo)
- [Try::Tiny](https://metacpan.org/pod/Try::Tiny)
- [Unexpected](https://metacpan.org/pod/Unexpected)

# Incompatibilities

OpenDNS. I have received reports that hosts configured to use OpenDNS fail the
`isValidHostname` test. Apparently OpenDNS causes the core Perl function
`gethostbyname` to return it's argument rather than undefined as per the
documentation

# Bugs and Limitations

There are no known bugs in this module. Please report problems to
http://rt.cpan.org/NoAuth/Bugs.html?Dist=Data-Validation.  Patches are welcome

# Acknowledgements

Larry Wall - For the Perl programming language

# Author

Peter Flanigan, `<pjfl@cpan.org>`

# License and Copyright

Copyright (c) 2017 Peter Flanigan. All rights reserved

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See [perlartistic](https://metacpan.org/pod/perlartistic)

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE
