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
  plan tests => 5;
  use_ok ('Games::Irrlicht');
  }

can_ok ('Games::Irrlicht', qw/ 
  new _next_frame _init
  hide_mouse_cursor
  addCameraSceneNodeFPS 
  getPrimitiveCountDrawn
  /);

my $app = Games::Irrlicht->new();

is (ref($app), 'Games::Irrlicht');

my $i = 0;
while ($i++ < 70)
  {
  $app->_next_frame();
  }

is ($app->getPrimitiveCountDrawn(), 0, 'primitives drawn');

$app->addCameraSceneNodeFPS();

is ($app->addZipFileArchive('media/test.zip'), 1,
  'Could add zip file');

# debug XXX TODO (this actually works)
#$app->addZipFileArchive('../examples/media/map-20kdm2.pk3');
#$app->loadBSP ("20kdm2.bsp");

