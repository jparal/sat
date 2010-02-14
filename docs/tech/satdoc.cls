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
