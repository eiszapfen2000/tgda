* README for epilog poster template $Id: README.poster 7657 2011-06-24 13:22:47Z tkren $ -*- org -*-

This README provides some information for the LaTeX templates for
epilog posters of the Faculty of Informatics, Vienna University of
Technology. You should be able to compile the files using pdflatex
(sorry, plain latex is not supported and will never be).

This template uses the beamer document class and beamerposter package, see
<http://www.ctan.org/tex-archive/macros/latex/contrib/beamer/> and
<http://www.ctan.org/tex-archive/macros/latex/contrib/beamerposter/>
for a comprehensive manual. The webpage at
<http://www-i6.informatik.rwth-aachen.de/~dreuw/latexbeamerposter.php>
provides additional information and example posters, the group
<http://groups.google.com/group/beamerposter> provides help.

If you find any errors or bugs, or if you have suggestions, please
drop me an email: Thomas Krennwallner <tkren@kr.tuwien.ac.at>.


INF_Poster_LaTeX.zip contains the files:

INF_Poster.tex          ... minimal poster
INF_Poster_example.tex  ... example poster
TUINFPST.sty            ... TUINFPST package, contains some page settings
beamerposter.sty        ... the newest beamerposter package 
beamerthemeTUINF.sty    ... the TUINF header and footer setting
figures/*               ... PDF figures


The information for the poster header and footer must be configured
using the following set of macros:

% [master study] and {title of master thesis}
\title[Computational Intelligence]{Interactive Computer Generated Architecture}

% [email] and {Name}
\author[martina.muster@alumni.tuwien.ac.at]{Martina Muster}

% TU, Institute, Department, and supervisor
\institute[]{%
  Technische Universit{\"a}t Wien\\[0.25\baselineskip]
  Institut f{\"u}r Informationssysteme\\[0.25\baselineskip]
  Arbeitsbereich: Wissensbasierte Systeme\\[0.25\baselineskip]
  BetreuerIn: Ao.Univ.-Prof. Dr. Maxima Musterfrau
}

% Department logo as \includegraphics
\titlegraphic{\includegraphics[height=52mm]{logo-KBS}}

** Convert your graphics into CMYK color model

Beware that poster plotters use the CMYK color model
<http://en.wikipedia.org/wiki/CMYK_color_model>, this means that your
color graphics may look differently on your RGB-based computer screen
compared to the print-out. You can avoid surprises by converting your
images from RGB to CMYK before you compile them into one A0
poster. The ghostscript package may help:

$ gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite "-sOutputFile=image_cmyk.pdf" -dProcessColorModel=/DeviceCMYK -f image.pdf

converts image.pdf to the CMYK-based image_cmyk.pdf.

** Embed your fonts

You cannot be sure that your print shop has all possible fonts
installed, this is why its best to embed all used fonts. Again,
ghostscript comes to the rescue:

$ gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress "-sOutputFile=file_embed.pdf" file.pdf

You can check that all fonts are embedded with pdffonts:

$ pdffonts INF_Poster.pdf
name                                 type              emb sub uni object ID
------------------------------------ ----------------- --- --- --- ---------
KODEWA+NimbusSanL-Regu               Type 1            yes yes no      16  0
OMQHKW+NimbusSanL-Bold               Type 1            yes yes no      17  0
OMQHKW+NimbusSanL-Bold               Type 1            yes yes no      30  0

The "emb" column should have all entries set to "yes".
