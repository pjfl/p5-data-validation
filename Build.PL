# @(#)$Ident: Build.PL 2013-08-07 00:04 pjf ;

use strict;
use warnings;
use inc::Bob; # Module::Build subclass
use version; our $VERSION = qv( sprintf '0.13.%d', q$Rev: 1 $ =~ /\d+/gmx );

Bob->new( {
   module    => q(Data::Validation),
   home_page => q(http://www.roxsoft.co.uk),
   requires  => {
      'perl'             => 5.010001,
      'namespace::sweep' => 0.006,
      'Class::Load'      => 0.18,
      'Email::Valid'     => 0.184,
      'LWP::UserAgent'   => 2.036,
      'Moo'              => 1.003000,
      'Regexp::Common'   => 2010010201,
      'Try::Tiny'        => 0.09,
      'Unexpected'       => q(0.6.0), },
   recommends                => {
      'App::cpanminus'       => 1.6005,
      'Class::Usul'          => q(0.22.0), },
   configure_requires        => {
      'version'              => 0.88,
      'Module::Build'        => 0.4004, },
   build_requires            => {
      'version'              => 0.88,
      'Class::Null'          => 1.09,
      'Exception::Class'     => 1.23,
      'Module::Build'        => 0.4004,
      'Test::Pod'            => 1.26, },
} )->create_build_script; # Goal!

# Local Variables:
# eval: (load-project-state "data-validation")
# mode: perl
# tab-title: Validation
# tab-width: 3
# End:
