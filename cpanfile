requires "Email::Valid" => "1.195";
requires "Exporter::Tiny" => "0.042";
requires "HTTP::Tiny" => "0.054";
requires "Module::Runtime" => "0.014";
requires "Moo" => "2.000001";
requires "Regexp::Common" => "2013031301";
requires "Try::Tiny" => "0.22";
requires "Unexpected" => "v0.38.0";
requires "namespace::autoclean" => "0.22";
requires "perl" => "5.010001";
recommends "Class::Usul" => "v0.58.0";

on 'build' => sub {
  requires "Class::Null" => "1.09";
  requires "Module::Build" => "0.4004";
  requires "version" => "0.88";
};

on 'configure' => sub {
  requires "Module::Build" => "0.4004";
  requires "version" => "0.88";
};
