# This file is part of Autoconf.                       -*- Autoconf -*-

# Copyright (C) 2004 Oren Ben-Kiki
# This file is distributed under the same terms as the Autoconf macro files.

# Generate automatic documentation using Doxygen. Works in concert with the
# aminclude.m4 file and a compatible doxygen configuration file. Defines the
# following public macros:
#
# DX_???_FEATURE(ON|OFF) - control the default setting fo a Doxygen feature.
# Supported features are 'DOXYGEN' itself, 'DOT' for generating graphics,
# 'HTML' for plain HTML, 'CHM' for compressed HTML help (for MS users), 'CHI'
# for generating a seperate .chi file by the .chm file, and 'MAN', 'RTF',
# 'XML', 'PDF' and 'PS' for the appropriate output formats. The environment
# variable DOXYGEN_PAPER_SIZE may be specified to override the default 'a4wide'
# paper size.
#
# By default, HTML, PDF and PS documentation is generated as this seems to be
# the most popular and portable combination. MAN pages created by Doxygen are
# usually problematic, though by picking an appropriate subset and doing some
# massaging they might be better than nothing. CHM and RTF are specific for MS
# (note that you can't generate both HTML and CHM at the same time). The XML is
# rather useless unless you apply specialized post-processing to it.
#
# The macro mainly controls the default state of the feature. The use can
# override the default by specifying --enable or --disable. The macros ensure
# that contradictory flags are not given (e.g., --enable-doxygen-html and
# --enable-doxygen-chm, --enable-doxygen-anything with --disable-doxygen, etc.)
# Finally, each feature will be automatically disabled (with a warning) if the
# required programs are missing.
#
# Once all the feature defaults have been specified, call DX_INIT_DOXYGEN with
# the following parameters: a one-word name for the project for use as a
# filename base etc., an optional configuration file name (the default is
# 'Doxyfile', the same as Doxygen's default), and an optional output directory
# name (the default is 'doxygen-doc').

## ----------##
## Defaults. ##
## ----------##

DX_ENV=""
AC_DEFUN([DX_FEATURE_doc],  ON)
AC_DEFUN([DX_FEATURE_dot],  ON)
AC_DEFUN([DX_FEATURE_man],  ON)
AC_DEFUN([DX_FEATURE_html], ON)
AC_DEFUN([DX_FEATURE_chm],  OFF)
AC_DEFUN([DX_FEATURE_chi],  OFF)
AC_DEFUN([DX_FEATURE_rtf],  OFF)
AC_DEFUN([DX_FEATURE_xml],  OFF)
AC_DEFUN([DX_FEATURE_pdf],  OFF)
AC_DEFUN([DX_FEATURE_ps],   OFF)

## --------------- ##
## Private macros. ##
## --------------- ##

# DX_ENV_APPEND(VARIABLE, VALUE)
# ------------------------------
# Append VARIABLE="VALUE" to DX_ENV for invoking doxygen.
AC_DEFUN([DX_ENV_APPEND], [AC_SUBST([DX_ENV], ["$DX_ENV $1='$2'"])])

# DX_DIRNAME_EXPR
# ---------------
# Expand into a shell expression prints the directory part of a path.
AC_DEFUN([DX_DIRNAME_EXPR],
         [[expr ".$1" : '\(\.\)[^/]*$' \| "x$1" : 'x\(.*\)/[^/]*$']])

# DX_IF_FEATURE(FEATURE, IF-ON, IF-OFF)
# -------------------------------------
# Expands according to the M4 (static) status of the feature.
AC_DEFUN([DX_IF_FEATURE], [ifelse(DX_FEATURE_$1, ON, [$2], [$3])])

# DX_REQUIRE_PROG(VARIABLE, PROGRAM)
# ----------------------------------
# Require the specified program to be found for the DX_CURRENT_FEATURE to work.
AC_DEFUN([DX_REQUIRE_PROG], [
AC_PATH_TOOL([$1], [$2])
if test "$DX_FLAG_[]DX_CURRENT_FEATURE$$1" = 1; then
    AC_MSG_WARN([$2 not found - will not DX_CURRENT_DESCRIPTION])
    AC_SUBST([DX_FLAG_[]DX_CURRENT_FEATURE], 0)
fi
])

# DX_TEST_FEATURE(FEATURE)
# ------------------------
# Expand to a shell expression testing whether the feature is active.
AC_DEFUN([DX_TEST_FEATURE], [test "$DX_FLAG_$1" = 1])

# DX_CHECK_DEPEND(REQUIRED_FEATURE, REQUIRED_STATE)
# -------------------------------------------------
# Verify that a required features has the right state before trying to turn on
# the DX_CURRENT_FEATURE.
AC_DEFUN([DX_CHECK_DEPEND], [
test "$DX_FLAG_$1" = "$2" \
|| AC_MSG_ERROR([doxygen-DX_CURRENT_FEATURE ifelse([$2], 1,
                            requires, contradicts) doxygen-DX_CURRENT_FEATURE])
])

# DX_CLEAR_DEPEND(FEATURE, REQUIRED_FEATURE, REQUIRED_STATE)
# ----------------------------------------------------------
# Turn off the DX_CURRENT_FEATURE if the required feature is off.
AC_DEFUN([DX_CLEAR_DEPEND], [
test "$DX_FLAG_$1" = "$2" || AC_SUBST([DX_FLAG_[]DX_CURRENT_FEATURE], 0)
])

# DX_FEATURE_ARG(FEATURE, DESCRIPTION,
#                CHECK_DEPEND, CLEAR_DEPEND,
#                REQUIRE, DO-IF-ON, DO-IF-OFF)
# --------------------------------------------
# Parse the command-line option controlling a feature. CHECK_DEPEND is called
# if the user explicitly turns the feature on (and invokes DX_CHECK_DEPEND),
# otherwise CLEAR_DEPEND is called to turn off the default state if a required
# feature is disabled (using DX_CLEAR_DEPEND). REQUIRE performs additional
# requirement tests (DX_REQUIRE_PROG). Finally, an automake flag is set and
# DO-IF-ON or DO-IF-OFF are called according to the final state of the feature.
AC_DEFUN([DX_ARG_ABLE], [
    AC_DEFUN([DX_CURRENT_FEATURE], [$1])
    AC_DEFUN([DX_CURRENT_DESCRIPTION], [$2])
    AC_ARG_ENABLE(doxygen-$1,
                  [AS_HELP_STRING(DX_IF_FEATURE([$1], [--disable-doxygen-$1],
                                                      [--enable-doxygen-$1]),
                                  DX_IF_FEATURE([$1], [don't $2], [$2]))],
                  [
case "$enableval" in
#(
y|Y|yes|Yes|YES)
    AC_SUBST([DX_FLAG_$1], 1)
    $3
;; #(
n|N|no|No|NO)
    AC_SUBST([DX_FLAG_$1], 0)
;; #(
*)
    AC_MSG_ERROR([invalid value '$enableval' given to doxygen-$1])
;;
esac
], [
AC_SUBST([DX_FLAG_$1], [DX_IF_FEATURE([$1], 1, 0)])
$4
])
if DX_TEST_FEATURE([$1]); then
    $5
    :
fi
if DX_TEST_FEATURE([$1]); then
    AM_CONDITIONAL(DX_COND_$1, :)
    $6
    :
else
    AM_CONDITIONAL(DX_COND_$1, false)
    $7
    :
fi
])

## -------------- ##
## Public macros. ##
## -------------- ##

# DX_XXX_FEATURE(DEFAULT_STATE)
# -----------------------------
AC_DEFUN([DX_DOXYGEN_FEATURE], [AC_DEFUN([DX_FEATURE_doc],  [$1])])
AC_DEFUN([DX_MAN_FEATURE],     [AC_DEFUN([DX_FEATURE_man],  [$1])])
AC_DEFUN([DX_HTML_FEATURE],    [AC_DEFUN([DX_FEATURE_html], [$1])])
AC_DEFUN([DX_CHM_FEATURE],     [AC_DEFUN([DX_FEATURE_chm],  [$1])])
AC_DEFUN([DX_CHI_FEATURE],     [AC_DEFUN([DX_FEATURE_chi],  [$1])])
AC_DEFUN([DX_RTF_FEATURE],     [AC_DEFUN([DX_FEATURE_rtf],  [$1])])
AC_DEFUN([DX_XML_FEATURE],     [AC_DEFUN([DX_FEATURE_xml],  [$1])])
AC_DEFUN([DX_XML_FEATURE],     [AC_DEFUN([DX_FEATURE_xml],  [$1])])
AC_DEFUN([DX_PDF_FEATURE],     [AC_DEFUN([DX_FEATURE_pdf],  [$1])])
AC_DEFUN([DX_PS_FEATURE],      [AC_DEFUN([DX_FEATURE_ps],   [$1])])

# DX_INIT_DOXYGEN(PROJECT, [CONFIG-FILE], [OUTPUT-DOC-DIR])
# ---------------------------------------------------------
# PROJECT also serves as the base name for the documentation files.
# The default CONFIG-FILE is "Doxyfile" and OUTPUT-DOC-DIR is "doxygen-doc".
AC_DEFUN([DX_INIT_DOXYGEN], [

# Files:
AC_SUBST([DX_PROJECT], [$1])
AC_SUBST([DX_CONFIG], [ifelse([$2], [], Doxyfile, [$2])])
AC_SUBST([DX_DOCDIR], [ifelse([$3], [], doxygen-doc, [$3])])

# Environment variables used inside doxygen.cfg:
DX_ENV_APPEND(SRCDIR, $srcdir)
DX_ENV_APPEND(PROJECT, $DX_PROJECT)
DX_ENV_APPEND(DOCDIR, $DX_DOCDIR)
DX_ENV_APPEND(VERSION, $SAT_VERSION)
DX_ENV_APPEND(MAINTAINERS, `cat $srcdir/docs/MAINTAINERS`)

# Doxygen itself:
DX_ARG_ABLE(doc, [generate any doxygen documentation],
            [],
            [],
            [DX_REQUIRE_PROG([DX_DOXYGEN], doxygen)
             DX_REQUIRE_PROG([DX_PERL], perl)],
            [DX_ENV_APPEND(PERL_PATH, $DX_PERL)])

# Dot for graphics:
DX_ARG_ABLE(dot, [generate graphics for doxygen documentation],
            [DX_CHECK_DEPEND(doc, 1)],
            [DX_CLEAR_DEPEND(doc, 1)],
            [DX_REQUIRE_PROG([DX_DOT], dot)],
            [DX_ENV_APPEND(HAVE_DOT, YES)
             DX_ENV_APPEND(DOT_PATH, [`DX_DIRNAME_EXPR($DX_DOT)`])],
            [DX_ENV_APPEND(HAVE_DOT, NO)])

dnl # Plain HTML pages generation:
dnl DX_ARG_ABLE(html, [generate doxygen plain HTML documentation],
dnl             [DX_CHECK_DEPEND(doc, 1) DX_CHECK_DEPEND(chm, 0)],
dnl             [DX_CLEAR_DEPEND(doc, 1) DX_CLEAR_DEPEND(chm, 0)],
dnl             [],
dnl             [DX_ENV_APPEND(GENERATE_HTML, YES)],
dnl             [DX_TEST_FEATURE(chm) || DX_ENV_APPEND(GENERATE_HTML, NO)])

dnl # Man pages generation:
dnl DX_ARG_ABLE(man, [generate doxygen manual pages],
dnl             [DX_CHECK_DEPEND(doc, 1)],
dnl             [DX_CLEAR_DEPEND(doc, 1)],
dnl             [],
dnl             [DX_ENV_APPEND(GENERATE_MAN, YES)],
dnl             [DX_ENV_APPEND(GENERATE_MAN, NO)])

dnl # RTF file generation:
dnl DX_ARG_ABLE(rtf, [generate doxygen RTF documentation],
dnl             [DX_CHECK_DEPEND(doc, 1)],
dnl             [DX_CLEAR_DEPEND(doc, 1)],
dnl             [],
dnl             [DX_ENV_APPEND(GENERATE_RTF, YES)],
dnl             [DX_ENV_APPEND(GENERATE_RTF, NO)])

dnl # XML file generation:
dnl DX_ARG_ABLE(xml, [generate doxygen XML documentation],
dnl             [DX_CHECK_DEPEND(doc, 1)],
dnl             [DX_CLEAR_DEPEND(doc, 1)],
dnl             [],
dnl             [DX_ENV_APPEND(GENERATE_XML, YES)],
dnl             [DX_ENV_APPEND(GENERATE_XML, NO)])

dnl # (Compressed) HTML help generation:
dnl DX_ARG_ABLE(chm, [generate doxygen compressed HTML help documentation],
dnl             [DX_CHECK_DEPEND(doc, 1)],
dnl             [DX_CLEAR_DEPEND(doc, 1)],
dnl             [DX_REQUIRE_PROG([DX_HHC], hhc)],
dnl             [DX_ENV_APPEND(HHC_PATH, $DX_HHC)
dnl              DX_ENV_APPEND(GENERATE_HTML, YES)
dnl              DX_ENV_APPEND(GENERATE_HTMLHELP, YES)],
dnl             [DX_ENV_APPEND(GENERATE_HTMLHELP, NO)])

dnl # Seperate CHI file generation.
dnl DX_ARG_ABLE(chi, [generate doxygen seperate compressed HTML help index file],
dnl             [DX_CHECK_DEPEND(chm, 1)],
dnl             [DX_CLEAR_DEPEND(chm, 1)],
dnl             [],
dnl             [DX_ENV_APPEND(GENERATE_CHI, YES)],
dnl             [DX_ENV_APPEND(GENERATE_CHI, NO)])

dnl # PostScript file generation:
dnl DX_ARG_ABLE(ps, [generate doxygen PostScript documentation],
dnl             [DX_CHECK_DEPEND(doc, 1)],
dnl             [DX_CLEAR_DEPEND(doc, 1)],
dnl             [DX_REQUIRE_PROG([DX_LATEX], latex)
dnl              DX_REQUIRE_PROG([DX_MAKEINDEX], makeindex)
dnl              DX_REQUIRE_PROG([DX_DVIPS], dvips)
dnl              DX_REQUIRE_PROG([DX_EGREP], egrep)])

dnl # PDF file generation:
dnl DX_ARG_ABLE(pdf, [generate doxygen PDF documentation],
dnl             [DX_CHECK_DEPEND(doc, 1)],
dnl             [DX_CLEAR_DEPEND(doc, 1)],
dnl             [DX_REQUIRE_PROG([DX_PDFLATEX], pdflatex)
dnl              DX_REQUIRE_PROG([DX_MAKEINDEX], makeindex)
dnl              DX_REQUIRE_PROG([DX_EGREP], egrep)])

dnl # LaTeX generation for PS and/or PDF:
dnl if DX_TEST_FEATURE(ps) || DX_TEST_FEATURE(pdf); then
dnl     AM_CONDITIONAL(DX_COND_latex, :)
dnl     DX_ENV_APPEND(GENERATE_LATEX, YES)
dnl else
dnl     AM_CONDITIONAL(DX_COND_latex, false)
dnl     DX_ENV_APPEND(GENERATE_LATEX, NO)
dnl fi

dnl # Paper size for PS and/or PDF:
dnl AC_ARG_VAR(DOXYGEN_PAPER_SIZE,
dnl            [a4wide (default), a4, letter, legal or executive])
dnl case "$DOXYGEN_PAPER_SIZE" in
dnl #(
dnl "")
dnl     AC_SUBST(DOXYGEN_PAPER_SIZE, "")
dnl ;; #(
dnl a4wide|a4|letter|legal|executive)
dnl     DX_ENV_APPEND(PAPER_SIZE, $DOXYGEN_PAPER_SIZE)
dnl ;; #(
dnl *)
dnl     AC_MSG_ERROR([unknown DOXYGEN_PAPER_SIZE='$DOXYGEN_PAPER_SIZE'])
dnl ;;
dnl esac

#For debugging:
#echo DX_FLAG_doc=$DX_FLAG_doc
#echo DX_FLAG_dot=$DX_FLAG_dot
#echo DX_FLAG_man=$DX_FLAG_man
#echo DX_FLAG_html=$DX_FLAG_html
#echo DX_FLAG_chm=$DX_FLAG_chm
#echo DX_FLAG_chi=$DX_FLAG_chi
#echo DX_FLAG_rtf=$DX_FLAG_rtf
#echo DX_FLAG_xml=$DX_FLAG_xml
#echo DX_FLAG_pdf=$DX_FLAG_pdf
#echo DX_FLAG_ps=$DX_FLAG_ps
#echo DX_ENV=$DX_ENV
])
