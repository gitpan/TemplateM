#########################################################################
#
# Lepenkov Sergey (Serz Minus), <minus@mail333.com>
#
# Copyright (C) 1998-2010 D&D Corporation. All Rights Reserved
# 
# This is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
#
# $Id: 02-use-galore.t,v 1.1 2010/12/18 16:58:39 abalama Exp $
#
#########################################################################

use Test::More tests => 4;
BEGIN { use_ok('TemplateM', 'galore'); };
is(TemplateM->VERSION,'3.00','version checking');
my $tpl;
$tpl = new_ok(TemplateM=>[-template=>''],'TemplateM');
is($tpl && $tpl->scheme(),'galore','module checking');
