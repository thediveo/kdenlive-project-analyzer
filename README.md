# A Kdenlive Project XML Analyzer

The Kdenlive Project XML Analyzer is a simple tool that can shed some light on what's going on inside
Kdelive XML project files. Please note that only more recent Kdenlive project files are supported,
around Kdenlive 16.04 and later.

The analyzer shows the following information:
- **general project information**, such as project ID, document version, Kdenlive version, et cetera.
- **project bin contents**, neatly sorted into folders as in Kdenlive's project bin.
- **timeline tracks configuration**, with track title and properties, such as muted, hidden, locked, and so on.
- **internally added Transitions**, now this is something Kdenlive never shows you,
  but in case your project exhibits odd audio mixing or video compositing behavior, this may be the place to check:
  - *video compositing transitions:* which ones and between which tracks, neatly sorted and grouped.
  - *audio mixing transitions:* which ones on which tracks.
- **clip list**, just plain flat and sorted by name (no folders here).

# Installation

There is no specific installation; simply download/clone this project into its own directory.

# Starting the Analyzer

Simply load the file `kdenlive-project-analyzer.html` that's inside the main folder for this project
into your Firefox web browser. (Some other web browsers may work too, if they support XSLT 1.0 and
the regexp XPath extension.)

You should now see a simple form with a file chooser. Simply select a .kdenlive project file ...
and off you go. You should now see an analysis report shown below the form.
