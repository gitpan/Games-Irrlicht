#!/usr/bin/perl -w

use Test::More tests => 1;
use strict;

chdir 't' if -d 't';
`cd ..; ./m`;

is (1,1);
