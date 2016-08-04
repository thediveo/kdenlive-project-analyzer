# A Kdenlive Project XML Analyzer

The Kdenlive Project XML Analyzer is a simple tool that can shed some light on what's going on inside
Kdelive XML project files. Please note that only Kdenlive project files from around 15.08 and later are supported. There is no support for old Kdenlive 0.9.x projects (and never will be).

The analyzer shows the following information:
- **general project information**, such as project ID, document version, Kdenlive version, et cetera.
- **general project statistics**, such as number of (bin) clips, title clips, audio clips, timeline clips, overall timeline length, and more.
- **project bin contents**, neatly sorted into folders as in Kdenlive's project bin.
- **timeline tracks configuration**, with track title and properties, such as muted, hidden, locked, and so on.
- **internally added Transitions**, now this is something Kdenlive never shows you,
  but in case your project exhibits odd audio mixing or video compositing behavior, this may be the place to check:
  - **video compositing transitions:** which ones and between which tracks, neatly sorted and grouped.
  - **audio mixing transitions:** which ones on which tracks.
- **clip list**, just plain flat and sorted by name (no folders here).

# Online Kdenlive Project Analyzer

You can try our [Kdenlive Project Analyzer online](https://thediveo.github.io/kdenlive-project-analyzer/kdenlive-project-analyzer.html)
(Chrome/Chromium, Firefox, and any recent web browser with decent JavaScript support) without any installation.
This way, you can easily and quickly check your Kdenlive project files. As the analyzer runs only locally *inside*
your web browser, we and GitHub won't ever see your precious projects. The analyzer never uploads any files!

# Local Installation

There is no specific installation; simply download/clone this project into its own directory. Then please install
the the `Saxonce` folder from the [Saxon-CE XSLT 2.0 distribution](http://www.saxonica.com/ce/index.xml) into your local Kdenlive Project Analyzer copy (keeping the `Saxonce` folder). That's all.

# Starting the Analyzer

Simply load the file `kdenlive-project-analyzer.html` that's inside the main folder for this project
into your Chrome/Chromium, or Firefox web browser. Thanks to the fine JavaScript-based Saxon-CE XSLT 2.0/XPath 2.0 engine, the
project analyzer now works with most recent and decent web browsers.

You should now see a simple form with a file chooser. Just select a `.kdenlive` project file ...
and off you go. After a few seconds should see an analysis report below the form.

# Licenses

## Kdenlive Project Analyzer License

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

## Saxon CE License

The Kdenlive Project Analyzer now uses the fine [Saxon-CE](http://www.saxonica.com/ce/index.xml),
which is a XSLT 2.0/XPath 2.0 engine done in JavaScript. Saxon-CE is covered by the MPL 2 license,
see <https://www.mozilla.org/en-US/MPL/2.0>. For more information about further components of
Saxon-CE, please refer to its licences notics, see <https://github.com/Saxonica/Saxon-CE/tree/master/notices>.

## Font Awesome License

The Kdenlive Project Analyzer uses the awesome Font Awesome by Dave Gandy (http://fontawesome.io) to display
useful icons, such as folders, film, and audio icons for better UI experience. For your convenience,
this repository already contains the required CSS and font files. The font files of Font Awesome 4.6.3 itself are licensed
under the SIL OFL 1.1, the CSS files are licensed under the MIT License.
