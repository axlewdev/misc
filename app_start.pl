#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;
use Mojolicious::Commands;


Mojolicious::Commands->start_app('Theapp');