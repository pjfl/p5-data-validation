# @(#)$Id$

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );

use English qw( -no_match_vars );
use Module::Build;

sub whimper { my $text = shift; print {*STDOUT} $text."\n"; exit 0 }

BEGIN {
   eval { require 5.008; }; $EVAL_ERROR and whimper 'Perl minimum 5.8';
}

Module::Build->new
   ( add_to_cleanup     => [ 'Debian_CPANTS.txt', 'Data-Validation-*',
                             map { ( '*/' x $_ ) . '*~' } 0..5 ],
     build_requires     => { 'Exception::Class' => q(1.23),
                             'Class::Null'      => q(1.09),
                             'Test::More'       => q(0.74),
                             'Test::Pod'        => q(1.26), },
     configure_requires => { 'version'          => q(0.74), },
     create_readme      => 1,
     create_packlist    => 0,
     dist_version_from  => q(lib/Data/Validation.pm),
     license            => q(perl),
     module_name        => q(Data::Validation),
     no_index           => { directory => [ q(t) ] },
     recommends         => { 'CatalystX::Usul::Time' => q(0.3.0), },
     requires           => {
        'perl'                         => q(5.008),
        'charnames'                    => q(1.05),
        'namespace::autoclean'         => q(0.05),
        'version'                      => q(0.74),
        'Class::MOP'                   => q(0.53),
        'Email::Valid'                 => q(0.179),
        'List::Util'                   => q(1.19),
        'LWP::UserAgent'               => q(2.036),
        'Moose'                        => q(0.38),
        'Moose::Role'                  => q(0.55),
        'Moose::Util::TypeConstraints' => q(0.21),
        'Regexp::Common'               => q(2.120),
        'Scalar::Util'                 => q(1.19), },
     sign               => 1, )->create_build_script();

# Local Variables:
# mode: perl
# tab-width: 3
# End:
