#########################################################################
#
# Serz Minus (Lepenkov Sergey), <minus@mail333.com>
# 
# Copyright (C) 1998-2013 D&D Corporation. All Rights Reserved
# 
# This is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
#
# $Id: 01-use-default.t 2 2013-04-02 10:51:49Z abalama $
#
#########################################################################

use Test::More tests => 2;
BEGIN { use_ok('TemplateM'); };
is(TemplateM->VERSION,'3.02','version checking');
