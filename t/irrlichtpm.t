#!/usr/bin/perl -w

use Test::More;
use strict;

BEGIN
  {
  $| = 1;
  use blib;
  use lib '../blib/lib';
  use lib '../blib/arch';
  chdir 't' if -d 't';
  plan tests => 3;
  use_ok ('Games::Irrlicht');
  }

can_ok ('Games::Irrlicht', qw/ 
  new _next_frame _init  
  /);

my $app = Games::Irrlicht->new();

is (ref($app), 'Games::Irrlicht');

my $i = 0;
while ($i++ < 1000)
  {
  $app->_next_frame();
  }
