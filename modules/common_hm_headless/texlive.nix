{pkgs, ...}: let
  tex = pkgs.texlive.withPackages (
    ps: with ps; [
      # texdoc # Recommended package to navigate the documentation
      bibtex
      latexmk
      latex-bin
      fontspec
      luatexja
      etoolbox
      setspace
      url # Deps of biblatex, hyperref
      float
      booktabs
      enumitem
      emptypage
      caption # Provides subcaption.sty
      tools # Provides multicol.sty. Deps of tcolorbox
      xcolor # Deps of todonotes
      amsmath
      amsfonts # Provides amsfonts.sty, amssymb.sty
      mathtools
      amscls # Provides amsthm.sty
      jknapltx # Provides mathrsfs.sty
      rsfs # Provides rsfs10. Required by jknapltx/mathrsfs.sty
      cancel
      stmaryrd
      siunitx
      pgf # Provides tikz.sty
      tikz-cd
      pgfplots
      geometry
      epstopdf-pkg # Provides epstopdf-base.sty. Required by graphics-def/luatex.def by graphics by geometry
      pdflscape # Provides pdflscape.sty. Required by geometry
      kvsetkeys # Deps of hyperref. Required by thmtools/thm-kv.sty
      thmtools
      mdframed
      kvoptions # Deps of biblatex, hyperref. Required by mdframed.sty
      zref # Provides zref-abspage.sty. Required by mdframed.sty
      kvdefinekeys # Provides kvdefinekeys.sty. Required by zref/zref-base.sty. Deps of hyperref
      etexcmds # Provides etexcmds.sty. Required by zref/zref-base.sty. Deps of hyperref
      auxhook # Provides auxhook.sty. Required by zref/zref-base.sty. Deps of hyperref
      needspace # Provides needspace.sty. Required by mdframed.sty
      xifthen
      ifmtarg # Provides ifmtarg.sty. Required by xifthen/xifthen.sty
      fancyhdr
      todonotes
      tcolorbox
      pdfcol # Provides pdfcol.sty. Required by tcolorbox/tcbbreakable.code.tex
      ps.import
      pdfpages

      infwarerr # Deps of hyperref
      ltxcmds # Deps of hyperref
      pdftexcmds # Deps of biblatex, hyperref
      xkeyval
    ]);
in {home.packages = [tex];}
