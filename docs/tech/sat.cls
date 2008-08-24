\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{sat}[2007/10/08 v0.8 Simulate & Analyse Toolkit report class]
\RequirePackage{graphics}
\RequirePackage{setspace}

\newcommand{\SATlogofile}{sat.eps}

\newif\if@SATlogo
\DeclareOption{logo}{\@SATlogotrue}
\DeclareOption{nologo}{\@SATlogofalse}

\newif\if@SATbranding
\DeclareOption{branding}{\@SATbrandingtrue}
\DeclareOption{nobranding}{\@SATbrandingfalse}

\newif\if@SATtwoside
\DeclareOption{oneside}{\@SATtwosidefalse}
\DeclareOption{twoside}{\@SATtwosidetrue}

\newif\if@SATopenright
\DeclareOption{openright}{\@SATopenrighttrue}
\DeclareOption{openany}{\@SATopenrightfalse}

\newif\if@SATbook
\DeclareOption{book}{\@SATbooktrue}
\DeclareOption{article}{\@SATbookfalse}

\newif\if@SATtoc
\DeclareOption{toc}{\@SATtoctrue}
\DeclareOption{notoc}{\@SATtocfalse}

\newcommand{\SATrevision}[3]{
  #1 & #2 & #3 \\
  \hline
}

\newif\if@SATrevisions
\@SATrevisionsfalse

\newcommand{\SATrevisions}{} \newcommand{\SATaddrevision}[3]{
  \@SATrevisionstrue \toks0 = \expandafter{\SATrevisions}
  \edef\SATrevisions{\the\toks0
    \noexpand\hfill\noexpand\SATrevision{#1}{#2}{#3}\noexpand\par} }

\newcommand{\@SATptsize}{}
\DeclareOption{10pt}{\renewcommand{\@SATptsize}{10pt}}
\DeclareOption{11pt}{\renewcommand{\@SATptsize}{11pt}}
\DeclareOption{12pt}{\renewcommand{\@SATptsize}{12pt}}

\ExecuteOptions{openright,11pt,oneside,logo,branding,toc,book,revisions}
\ProcessOptions*

%
% Load the class upon which we are based.
%

\if@SATbook
\LoadClass[\if@SATopenright{openright}\else{openany}\fi,
\@SATptsize,\if@SATtwoside{twoside}\else{oneside}\fi]{book}
\else
\LoadClass[\if@SATopenright{openright}\else{openany}\fi,\@SATptsize]{article}
\fi

%
% Set and adjust various lengths.
%

\setlength{\textwidth}{15.2cm}
\setlength{\textheight}{20cm}
\setlength{\topmargin}{-0.25in}
\setlength{\oddsidemargin}{.5cm}
%\setlength{\evensidemargin}{-1cm}
\setlength{\parindent}{0.25in}

%
% The required preamble commands are defined here.
%

% Version of the document
\newif\if@SATdocversion
\@SATdocversionfalse
\newcommand{\SATdocversion}[1]{%
   \@SATdocversiontrue
   \newcommand{\theSATdocversion}{#1}%
}

% Last modification of the document
\newif\if@SATmodification
\@SATmodificationfalse
\newcommand{\SATmodification}[1]{%
   \@SATmodificationtrue
   \newcommand{\theSATmodification}{#1}%
}

% Author and email
\newcommand{\SATauthor}[2]{%
  \newcommand{\theSATauthorname}{#1}%
  \newcommand{\theSATauthoremail}{#2}%
}


\newcommand{\makeSATtitlepage}{
   \cleardoublepage
   \begin{center}
      \vspace{\stretch{3}}
      {\bfseries\LARGE \@title}\par
      \vspace{\stretch{1}}

      by\par
      \vspace{\stretch{1}}
      {\bfseries\large \theSATauthorname}\\ \url{\theSATauthoremail} \par

      \vspace{\stretch{3}}
      \vspace{\stretch{1}}
      \if@SATbranding
      \if@SATlogo\resizebox{!}{15ex}{\includegraphics{\SATlogofile}}\fi
      \fi
   \end{center}

   \vspace{\stretch{3}}
   \begin{tabular*}{1.0\linewidth}{r|l}
     \if@SATdocversion
     \emph{Version}  & {\bfseries \theSATdocversion} \\
     \fi
     \if@SATmodification
     \emph{Last Modification} & {\bfseries \theSATmodification}
     \fi
   \end{tabular*}
   \par\vspace{\stretch{1}}
   \if@SATbranding
   \begin{flushright}
     {Simulate {\it\&} Analyse Toolkit \copyright}\par  
   \end{flushright}
   \fi
   \vspace*{\stretch{4}}
}


%
% The maketitle command is redefined so as to generate the correct sequence
% of prefaratory pages.
%

\renewcommand{\maketitle}{
   \renewcommand{\thepage}{}
   \@twosidefalse
    \begin{titlepage}
%       \makeSATlibraryreleaseform
%       \if@SATfrontis\makeSATfrontispiece\fi
       \makeSATtitlepage
%       \makeSATsignaturepage
%       \if@SATdedication\makeSATdedicationpage\fi
    \end{titlepage}
%    \makeSATabstractpage
%    \frontmatter\renewcommand{\thepage}{}
%    \if@SATpreface\makeSATpreface\fi
%    \if@SATacknowledge\makeSATacknowledgements\fi
   \global\let\maketitle\relax
   \global\let\title\relax
   \global\let\author\relax
   \cleardoublepage

   \if@SATrevisions
   \begin{tabular}{|p{.8in}|p{0.25in}|p{4in}|}
     \hline
     {\bf Date} & {\bf Rev.} & {\bf Description} \\
     \hline
     \SATrevisions
   \end{tabular}
   \newpage
   \fi

   \if@SATtoc
   \tableofcontents \newpage
   \fi

%    \if@SATlot\makeSATlistoftables\fi
%    \if@SATlof\makeSATlistoffigures\fi
%   \mainmatter
%   \if@SATtwoside\@twosidetrue\fi
%    \@SAT\spacing
   \pagenumbering{arabic}
   \if@SATbook
   \pagestyle{headings}
   \else
   \pagestyle{plain}
   \fi
}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%
\def\@citex[#1]#2{%
  \let\@citea\@empty
  \@cite{\@for\@citeb:=#2\do
    {\@citea\def\@citea{,\penalty\@m\ }%
     \edef\@citeb{\expandafter\@firstofone\@citeb}%
     \if@filesw\immediate\write\@auxout{\string\citation{\@citeb}}\fi
     \@ifundefined{b@\@citeb}{\mbox{\reset@font\bfseries ?}%
       \G@refundefinedtrue
       \@latex@warning
         {Citation `\@citeb' on page \thepage \space undefined}}%
       {%\hbox
{\csname b@\@citeb\endcsname}}}}{#1}}


%%%% Below:
%% Copyright 1993-1999 Patrick W Daly
%% Max-Planck-Institut f\"ur Aeronomie
%% Max-Planck-Str. 2
%% D-37191 Katlenburg-Lindau
%% Germany
%% E-mail: daly@linmpi.mpg.de
\def\ModuleVersion#1[#2]{}
    \ModuleVersion{natbib}
        [1999/05/28 7.0 (PWD)]
\newcommand\NAT@open{[} \newcommand\NAT@close{]}
\newcommand\NAT@sep{;} \newcommand\NAT@cmt{, }
\newcommand\NAT@aysep{,} \newcommand\NAT@yrsep{,~}
\def\NAT@sort{0}
\def\NAT@nmfmt#1{{\NAT@up#1}}
\renewcommand\@cite%
    [3]{\ifNAT@swa\NAT@@open\if*#2*\else#2\ \fi
        #1\if*#3*\else\NAT@cmt#3\fi\NAT@@close\else#1\fi\endgroup}
\providecommand\@firstofone[1]{#1}
\let\citenumfont=\relax
\def\@citex%
  [#1][#2]#3{%
  \NAT@sort@cites{#3}%
  \let\@citea\@empty
  \@cite{\let\NAT@nm\@empty\let\NAT@year\@empty
    \@for\@citeb:=\NAT@cite@list\do
    {\edef\@citeb{\expandafter\@firstofone\@citeb}%
     \if@filesw\immediate\write\@auxout{\string\citation{\@citeb}}\fi
     \@ifundefined{b@\@citeb\@extra@b@citeb}{\@citea%
       {\reset@font\bfseries ?}\NAT@citeundefined
                 \PackageWarning{natbib}%
       {Citation `\@citeb' on page \thepage \space undefined}\def\NAT@date{}}%
     {\let\NAT@last@nm=\NAT@nm\let\NAT@last@yr=\NAT@year
     \NAT@parse{\@citeb}%
     \ifNAT@full\let\NAT@nm\NAT@all@names\else
       \let\NAT@nm\NAT@name\fi
     \ifNAT@swa\ifcase\NAT@ctype
       \if\relax\NAT@date\relax
         \@citea\hyper@natlinkstart{\@citeb\@extra@b@citeb}%
         \NAT@nmfmt{\NAT@nm}\NAT@date\hyper@natlinkend
       \else
         \ifx\NAT@last@nm\NAT@nm\NAT@yrsep
            \ifx\NAT@last@yr\NAT@year
              \hyper@natlinkstart{\@citeb\@extra@b@citeb}\NAT@exlab
              \hyper@natlinkend
            \else\unskip\
              \hyper@natlinkstart{\@citeb\@extra@b@citeb}\NAT@date
              \hyper@natlinkend
            \fi
         \else\@citea\hyper@natlinkstart{\@citeb\@extra@b@citeb}%
           \NAT@nmfmt{\NAT@nm}%
           \hyper@natlinkbreak{\NAT@aysep\ }{\@citeb\@extra@b@citeb}%
           \NAT@date\hyper@natlinkend
         \fi
       \fi
     \or\@citea\hyper@natlinkstart{\@citeb\@extra@b@citeb}%
         \NAT@nmfmt{\NAT@nm}\hyper@natlinkend
     \or\@citea\hyper@natlinkstart{\@citeb\@extra@b@citeb}%
         \NAT@date\hyper@natlinkend
     \or\@citea\hyper@natlinkstart{\@citeb\@extra@b@citeb}%
         \NAT@alias\hyper@natlinkend
     \fi \def\@citea{\NAT@sep\ }%
     \else\ifcase\NAT@ctype
        \if\relax\NAT@date\relax
          \@citea\hyper@natlinkstart{\@citeb\@extra@b@citeb}%
          \NAT@nmfmt{\NAT@nm}\hyper@natlinkend
        \else
         \ifx\NAT@last@nm\NAT@nm\NAT@yrsep
            \ifx\NAT@last@yr\NAT@year
              \hyper@natlinkstart{\@citeb\@extra@b@citeb}\NAT@exlab
              \hyper@natlinkend
            \else\unskip\
              \hyper@natlinkstart{\@citeb\@extra@b@citeb}\NAT@date
              \hyper@natlinkend
            \fi
         \else\@citea\hyper@natlinkstart{\@citeb\@extra@b@citeb}%
           \NAT@nmfmt{\NAT@nm}%
           \hyper@natlinkbreak{\ \NAT@@open\if*#1*\else#1\ \fi}%
              {\@citeb\@extra@b@citeb}%
           \NAT@date\hyper@natlinkend\fi
        \fi
       \or\@citea\hyper@natlinkstart{\@citeb\@extra@b@citeb}%
         \NAT@nmfmt{\NAT@nm}\hyper@natlinkend
       \or\@citea\hyper@natlinkstart{\@citeb\@extra@b@citeb}%
         \NAT@date\hyper@natlinkend
       \or\@citea\hyper@natlinkstart{\@citeb\@extra@b@citeb}%
         \NAT@alias\hyper@natlinkend
       \fi \if\relax\NAT@date\relax\def\@citea{\NAT@sep\ }%
           \else\def\@citea{\NAT@@close\NAT@sep\ }\fi
     \fi
     }}\ifNAT@swa\else\if*#2*\else\NAT@cmt#2\fi
     \if\relax\NAT@date\relax\else\NAT@@close\fi\fi}{#1}{#2}}
\newif\ifNAT@par \NAT@partrue
\newcommand\NAT@@open{\ifNAT@par\NAT@open\fi}
\newcommand\NAT@@close{\ifNAT@par\NAT@close\fi}
\newcommand\NAT@alias{\@ifundefined{al@\@citeb\@extra@b@citeb}{%
  {\reset@font\bfseries(alias?)}\PackageWarning{natbib}
  {Alias undefined for citation `\@citeb'
  \MessageBreak on page \thepage}}{\@nameuse{al@\@citeb\@extra@b@citeb}}}
\let\NAT@up\relax
\newcommand\NAT@Up[1]{{\let\protect\@unexpandable@protect\let~\relax
  \expandafter\NAT@deftemp#1}\expandafter\NAT@UP\NAT@temp}
\newcommand\NAT@deftemp[1]{\xdef\NAT@temp{#1}}
\newcommand\NAT@UP[1]{\let\@tempa\NAT@UP\ifcat a#1\MakeUppercase{#1}%
  \let\@tempa\relax\else#1\fi\@tempa}
\renewcommand\@biblabel[1]{\hfill}
\AtBeginDocument{\ifx\SK@def\@undefined\else
\ifx\SK@cite\@empty\else
  \SK@def\@citex[#1][#2]#3{\SK@\SK@@ref{#3}\SK@@citex[#1][#2]{#3}}\fi
\ifx\SK@citeauthor\@undefined\def\HAR@checkdef{}\else
  \let\citeauthor\SK@citeauthor
  \let\citefullauthor\SK@citefullauthor
  \let\citeyear\SK@citeyear\fi
\fi}
\newif\ifNAT@full\NAT@fullfalse
\newif\ifNAT@swa
\DeclareRobustCommand\citet
   {\begingroup\NAT@swafalse\def\NAT@ctype{0}\NAT@partrue
     \@ifstar{\NAT@fulltrue\NAT@citetp}{\NAT@fullfalse\NAT@citetp}}
\newcommand\NAT@citetp{\@ifnextchar[{\NAT@@citetp}{\NAT@@citetp[]}}
\newcommand\NAT@@citetp{}
\def\NAT@@citetp[#1]{\@ifnextchar[{\@citex[#1]}{\@citex[][#1]}}
\DeclareRobustCommand\citep
   {\begingroup\NAT@swatrue\def\NAT@ctype{0}\NAT@partrue
         \@ifstar{\NAT@fulltrue\NAT@citetp}{\NAT@fullfalse\NAT@citetp}}
\DeclareRobustCommand\cite
    {\begingroup\def\NAT@ctype{0}\NAT@partrue\NAT@swatrue
      \@ifstar{\NAT@fulltrue\NAT@cites}{\NAT@fullfalse\NAT@cites}}
\newcommand\NAT@cites{\@ifnextchar [{\NAT@@citetp}{%
     \NAT@swafalse
    \NAT@@citetp[]}}
\DeclareRobustCommand\citealt
   {\begingroup\NAT@swafalse\def\NAT@ctype{0}\NAT@parfalse
         \@ifstar{\NAT@fulltrue\NAT@citetp}{\NAT@fullfalse\NAT@citetp}}
\DeclareRobustCommand\citealp
   {\begingroup\NAT@swatrue\def\NAT@ctype{0}\NAT@parfalse
         \@ifstar{\NAT@fulltrue\NAT@citetp}{\NAT@fullfalse\NAT@citetp}}
\DeclareRobustCommand\citeauthor
   {\begingroup\NAT@swafalse\def\NAT@ctype{1}\NAT@parfalse
    \@ifstar{\NAT@fulltrue\NAT@citetp}{\NAT@fullfalse\NAT@citetp}}
\DeclareRobustCommand\Citet
   {\begingroup\NAT@swafalse\def\NAT@ctype{0}\NAT@partrue
     \let\NAT@up\NAT@Up
     \@ifstar{\NAT@fulltrue\NAT@citetp}{\NAT@fullfalse\NAT@citetp}}
\DeclareRobustCommand\Citep
   {\begingroup\NAT@swatrue\def\NAT@ctype{0}\NAT@partrue
     \let\NAT@up\NAT@Up
         \@ifstar{\NAT@fulltrue\NAT@citetp}{\NAT@fullfalse\NAT@citetp}}
\DeclareRobustCommand\Citeauthor
   {\begingroup\NAT@swafalse\def\NAT@ctype{1}\NAT@parfalse
     \let\NAT@up\NAT@Up
    \@ifstar{\NAT@fulltrue\NAT@citetp}{\NAT@fullfalse\NAT@citetp}}
\DeclareRobustCommand\citeyear
   {\begingroup\NAT@swafalse\def\NAT@ctype{2}\NAT@parfalse\NAT@citetp}
\DeclareRobustCommand\citeyearpar
   {\begingroup\NAT@swatrue\def\NAT@ctype{2}\NAT@partrue\NAT@citetp}
\newcommand\citetext[1]{\NAT@open#1\NAT@close}
\DeclareRobustCommand\citefullauthor
   {\citeauthor*}
\newcommand\defcitealias[2]{%
   \@ifundefined{al@#1\@extra@b@citeb}{}
   {\PackageWarning{natbib}{Overwriting existing alias for citation #1}}
   \@namedef{al@#1\@extra@b@citeb}{#2}}
\DeclareRobustCommand\citetalias{\begingroup
   \NAT@swafalse\def\NAT@ctype{3}\NAT@parfalse\NAT@citetp}
\DeclareRobustCommand\citepalias{\begingroup
   \NAT@swatrue\def\NAT@ctype{3}\NAT@partrue\NAT@citetp}
\renewcommand\nocite[1]{\@bsphack
  \@for\@citeb:=#1\do{%
    \edef\@citeb{\expandafter\@firstofone\@citeb}%
    \if@filesw\immediate\write\@auxout{\string\citation{\@citeb}}\fi
    \if*\@citeb\else
    \@ifundefined{b@\@citeb\@extra@b@citeb}{%
       \NAT@citeundefined \PackageWarning{natbib}%
       {Citation `\@citeb' undefined}}{}\fi}%
  \@esphack}
\newcommand\NAT@parse[1]{{%
     \let\protect=\@unexpandable@protect\let~\relax
     \let\active@prefix=\@gobble
     \xdef\NAT@temp{\csname b@#1\@extra@b@citeb\endcsname}}%
     \expandafter\NAT@split\NAT@temp
     \expandafter\NAT@parse@date\NAT@date??????@@%
}
\newcommand\NAT@split[4]{%
  \gdef\NAT@num{#1}\gdef\NAT@name{#3}\gdef\NAT@date{#2}%
  \gdef\NAT@all@names{#4}%
  \ifx\NAT@noname\NAT@all@names \gdef\NAT@all@names{#3}\fi}
\newcommand\NAT@parse@date{}
\def\NAT@parse@date#1#2#3#4#5#6@@{%
  \ifnum\the\catcode`#1=11\def\NAT@year{}\def\NAT@exlab{#1}\else
  \ifnum\the\catcode`#2=11\def\NAT@year{#1}\def\NAT@exlab{#2}\else
  \ifnum\the\catcode`#3=11\def\NAT@year{#1#2}\def\NAT@exlab{#3}\else
  \ifnum\the\catcode`#4=11\def\NAT@year{#1#2#3}\def\NAT@exlab{#4}\else
    \def\NAT@year{#1#2#3#4}\def\NAT@exlab{{#5}}\fi\fi\fi\fi}
\newcommand\NAT@ifcmd{\futurelet\NAT@temp\NAT@ifxcmd}
\newcommand\NAT@ifxcmd{\ifx\NAT@temp\relax\else\expandafter\NAT@bare\fi}
\def\NAT@bare#1(#2)#3(@)#4\@nil#5{%
  \stepcounter{NAT@ctr}%
  \NAT@wrout{\arabic {NAT@ctr}}{#2}{#1}{#3}{#5}
}
\newcommand\NAT@wrout[5]{%
\if@filesw
      {\let\protect\noexpand\let~\relax
       \immediate
       \write\@auxout{\string\bibcite{#5}{{#1}{#2}{{#3}}{{#4}}}}}\fi
\ignorespaces}
\def\NAT@noname{{}}
\renewcommand\bibitem{%
  \@ifnextchar[{\@lbibitem}{%
    \stepcounter{NAT@ctr}\@lbibitem[\arabic{NAT@ctr}]}}
\def\@lbibitem[#1]#2{%
  \if\relax\@extra@b@citeb\relax\else
    \@ifundefined{br@#2\@extra@b@citeb}{}{%
     \@namedef{br@#2}{\@nameuse{br@#2\@extra@b@citeb}}}\fi
   \@ifundefined{b@#2\@extra@b@citeb}{\def\NAT@num{}}{\NAT@parse{#2}}%
   \item[\hfil\hyper@natanchorstart{#2\@extra@b@citeb}\@biblabel{\NAT@num}%
    \hyper@natanchorend]%
    \NAT@ifcmd#1(@)(@)\@nil{#2}}
\ifx\SK@lbibitem\@undefined\else
   \let\SK@lbibitem\@lbibitem
   \def\@lbibitem[#1]#2{%
     \SK@lbibitem[#1]{#2}\SK@\SK@@label{#2}\ignorespaces}\fi
\providecommand\bibcite{}
\renewcommand\bibcite[2]{\@ifundefined{b@#1\@extra@binfo}\relax
     {\NAT@citemultiple
      \PackageWarningNoLine{natbib}{Citation `#1' multiply defined}}%
  \global\@namedef{b@#1\@extra@binfo}{#2}}
\AtEndDocument{\NAT@swatrue\let\bibcite\NAT@testdef}
\newcommand\NAT@testdef[2]{%
  \def\NAT@temp{#2}\expandafter \ifx \csname b@#1\@extra@binfo\endcsname
    \NAT@temp \else \ifNAT@swa \NAT@swafalse
       \PackageWarningNoLine{natbib}{Citation(s) may have
          changed.\MessageBreak
          Rerun to get citations correct}\fi\fi}
\newcounter{NAT@ctr}
\let\aguthebib=\thebibliography
\def\thebibliography#1{\aguthebib{#1}}
\providecommand\reset@font{\relax}
\providecommand\bibname{Bibliography}
\providecommand\refname{References}
\newcommand\NAT@citeundefined{\gdef \NAT@undefined {%
    \PackageWarningNoLine{natbib}{There were undefined citations}}}
\let \NAT@undefined \relax
\newcommand\NAT@citemultiple{\gdef \NAT@multiple {%
    \PackageWarningNoLine{natbib}{There were multiply defined citations}}}
\let \NAT@multiple \relax
\AtEndDocument{\NAT@undefined\NAT@multiple}
\providecommand\@mkboth[2]{}
\providecommand\MakeUppercase{\uppercase}
\providecommand{\@extra@b@citeb}{}
\gdef\@extra@binfo{}
\providecommand\hyper@natanchorstart[1]{}
\providecommand\hyper@natanchorend{}
\providecommand\hyper@natlinkstart[1]{}
\providecommand\hyper@natlinkend{}
\providecommand\hyper@natlinkbreak[2]{#1}
\AtBeginDocument{\@ifundefined{bbl@redefine}{}{%
\let\@citex\org@@citex
\bbl@redefine\@citex[#1][#2]#3{%
  \@safe@activestrue\org@@citex[#1][#2]{#3}\@safe@activesfalse}%
\bbl@redefine\NAT@testdef#1#2{%
  \@safe@activestrue\org@NAT@testdef{#1}{#2}\@safe@activesfalse}%
\@ifundefined{org@@lbibitem}{%
\bbl@redefine\@lbibitem[#1]#2{%
  \@safe@activestrue\org@@lbibitem[#1]{#2}\@safe@activesfalse}}{}%
}}
\ifnum\NAT@sort>0
\newcommand\NAT@sort@cites[1]{%
\@tempcntb\m@ne
\let\@celt\delimiter
\def\NAT@num@list{}%
\def\NAT@cite@list{}%
\def\NAT@nonsort@list{}%
\@for \@citeb:=#1\do{\NAT@make@cite@list}%
\edef\NAT@cite@list{\NAT@cite@list\NAT@nonsort@list}%
\edef\NAT@cite@list{\expandafter\NAT@xcom\NAT@cite@list @@}}
\begingroup \catcode`\_=8
\gdef\NAT@make@cite@list{%
     \edef\@citeb{\expandafter\@firstofone\@citeb}%
    \@ifundefined{b@\@citeb\@extra@b@citeb}{\def\NAT@num{A}}%
    {\NAT@parse{\@citeb}}%
      \ifcat _\ifnum\z@<0\NAT@num _\else A\fi
       \@tempcnta\NAT@num \relax
       \ifnum \@tempcnta>\@tempcntb
          \edef\NAT@num@list{\NAT@num@list \@celt{\NAT@num}}%
          \edef\NAT@cite@list{\NAT@cite@list\@citeb,}%
          \@tempcntb\@tempcnta
       \else
          \let\NAT@@cite@list=\NAT@cite@list \def\NAT@cite@list{}%
          \edef\NAT@num@list{\expandafter\NAT@num@celt \NAT@num@list \@gobble @}%
          {\let\@celt=\NAT@celt\NAT@num@list}%
       \fi
    \else
       \edef\NAT@nonsort@list{\NAT@nonsort@list\@citeb,}%
 \fi}
\endgroup
\def\NAT@celt#1{\ifnum #1<\@tempcnta
  \xdef\NAT@cite@list{\NAT@cite@list\expandafter\NAT@nextc\NAT@@cite@list @@}%
  \xdef\NAT@@cite@list{\expandafter\NAT@restc\NAT@@cite@list}%
 \else
  \xdef\NAT@cite@list{\NAT@cite@list\@citeb,\NAT@@cite@list}\let\@celt\@gobble%
 \fi}
\def\NAT@num@celt#1#2{\ifx \@celt #1%
     \ifnum #2<\@tempcnta
        \@celt{#2}%
        \expandafter\expandafter\expandafter\NAT@num@celt
     \else
        \@celt{\number\@tempcnta}\@celt{#2}%
  \fi\fi}
\def\NAT@nextc#1,#2@@{#1,}
\def\NAT@restc#1,#2{#2}
\def\NAT@xcom#1,@@{#1}
\else
 \newcommand\NAT@sort@cites[1]{\edef\NAT@cite@list{#1}}\fi

%% Figbox due to Patrick Daly, orginally in aguplus.cls package

\def\figbox{\@ifstar{\let\agubox\makebox\@figbox}
  {\let\agubox\framebox\@figbox}}
\def\@figbox#1#2#3{\hbox to \hsize{\hfil
  \ifx!#1!\agubox{#3}\else
  \agubox[#1][c]{\ifx!#2!#3\else\@tempdima#2\relax
  \divide\@tempdima by2\relax
  \advance\@tempdima by-\fboxsep \advance\@tempdima by-\fboxrule
  \vrule\@height\@tempdima\@depth\@tempdima\@width\z@
  \vbox to \z@{\vss\hbox{#3}\vss}\fi}\fi\hfil}}

\newcommand{\btx}{\textsc{Bib}\TeX}

%%%%%%%%%%%%%% End Code from Patrick Daly %%%%%%%%%%%%%%
