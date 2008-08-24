##
## File:	$URL: file:///usr/casc/samrai/repository/SAMRAI/tags/v-2-3-0/source/toolbox/inputdb/genfiles.sh $
## Package:	SAMRAI toolbox
## Copyright:	(c) 1997-2008 Lawrence Livermore National Security, LLC
## Revision:	$LastChangedRevision: 1917 $
## Modified:	$LastChangedDate: 2008-01-25 13:28:01 -0800 (Fri, 25 Jan 2008) $
## Description:	simple shell script to generate flex and bison files
##

dir_name=`echo ${0} | sed -e 's:^\([^/]*\)$:./\1:' -e 's:/[^/]*$::'`;
cd $dir_name

#
# Use yacc since ASCI red does not support alloca() function used by bison
#

bison --defines --name-prefix=libconfig_yy grammar.y
perl fixgrammar.pl y.tab.c > grammar.c
perl fixgrammar.pl y.tab.h > grammar.h
rm y.tab.c
rm y.tab.h

#
# Scanner requires flex due to input reading method with MPI
#

flex --prefix=libconfig_yy scanner.l
perl fixscanner.pl lex.yy.c > scanner.c
rm lex.yy.c
