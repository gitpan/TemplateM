#########################################################################
#
# Lepenkov Sergey (Serz Minus), <minus@mail333.com>
#
# Copyright (C) 1998-2010 D&D Corporation. All Rights Reserved
# 
# This is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
#
# $Id: 01-use-default.t,v 1.1 2010/12/18 16:58:39 abalama Exp $
#
#########################################################################

use Test::More tests => 2;
BEGIN { use_ok('TemplateM'); };
is(TemplateM->VERSION,'3.00','version checking');

