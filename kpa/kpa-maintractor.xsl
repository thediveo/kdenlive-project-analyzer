<?xml version="1.0"?>
<!--
     Kdenlive Project XML Analyzer
     (c) 2016 Harald Albrecht

     For more details about the XML content of Kdenlive projects, please
     see: http://thediveo-e.blogspot.com/2016/07/inside-kdenlive-projects.html

     This program is free software: you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
     the Free Software Foundation, either version 3 of the License, or
     (at your option) any later version.

     This program is distributed in the hope that it will be useful,
     but WITHOUT ANY WARRANTY; without even the implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
     GNU General Public License for more details.

     You should have received a copy of the GNU General Public License
     along with this program.  If not, see <http://www.gnu.org/licenses/>.
  -->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


    <!-- The so-called "main tractor" is the most central element in Kdenlive
         projects. It references the individual timeline tracks, and houses
         all timeline transitions (both user transitions as well as internally
         added transitions).

         Please note that while we call it the "main tractor", internally it
         has the well-known id "maintractor" which is spelled without a space.

         Many other variables make use of the main tractor, so we decided to
         give it its own variable and XSLT module.
      -->
    <xsl:variable name="main-tractor" select="/mlt/tractor[@id='maintractor']"/>


</xsl:stylesheet>
