#!/usr/bin/perl -w

use Test::More tests => 7;
use strict;

BEGIN
  {
  $| = 1;
  use blib;
  use lib '../blib/lib';
  use lib '../blib/arch';
  chdir 't' if -d 't';
  use_ok ('Games::Irrlicht');
  }

can_ok ('Games::Irrlicht', qw/ 
  new _next_frame _init
  hide_mouse_cursor

  getIrrlichtDevice
  getFileSystem
  getGUIEnvironment
  getSzeneManager
  getVideoDriver
  
  /);

my $app = Games::Irrlicht->new( disable_log => 1 );

is (ref($app), 'Games::Irrlicht');

my $i = 0;
while ($i++ < 70)
  {
  $app->_next_frame();
  }

#############################################################################
# IrrlichDevice

my $device = $app->getIrrlichtDevice();

is ($device->setVisible(0), undef, 'set cursor to invisible');

#############################################################################
# VideoDriver

my $driver = $app->getVideoDriver();

is ($driver->getPrimitiveCountDrawn(), 0, 'no primitives drawn yet');

#############################################################################
# FileSystem

my $filesystem = $app->getFileSystem();

is ($filesystem->addZipFileArchive('media/test.zip'), 1,
  'Could add zip file');

#############################################################################
# SzeneManager

my $szmgr = $app->getSzeneManager();

is ($szmgr->addCameraSceneNodeFPS(), 1,
  'Could add FPS camera');

#############################################################################
# GUIEnvironment

my $gui = $app->getGUIEnvironment();

