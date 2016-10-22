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
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- Produce HTML5 document on an XSLT processor which does not
         support disable-output-escaping in order to generate the
         HTML5 !DOCTYPE. HTML5 thus defines a legacy doctype.
      -->
    <xsl:output method="html"
                doctype-system="about:legacy-compat"
                encoding="utf-8"
                indent="yes"/>

    <xsl:variable name="version" select="'0.9.12'"/>


    <!-- We later need this key to group clips by their "name", where "name" is
         a slightly involved concept. A clip name is either its name as explicitly
         assigned by the user, or the filename+extension, but without its file path.
      -->
    <xsl:key name="clipkey" match="producer" use="substring(concat(replace(property[@name='resource'],'.*/',''),property[@name='kdenlive:clipname']),1,1)"/>


    <!-- Parameters to this XSLT stylesheet -->
    <xsl:param name="project-name"/><!-- project URI/file name -->


    <!-- Pull in all the required modules -->
    <xsl:include href="kpa-maintractor.xsl"/>
    <xsl:include href="kpa-icons.xsl"/>
    <xsl:include href="kpa-utils.xsl"/>
    <xsl:include href="kpa-timeline-utils.xsl"/>
    <xsl:include href="kpa-main.xsl"/>
    <xsl:include href="kpa-project-information.xsl"/>
    <xsl:include href="kpa-project-statistics.xsl"/>
    <xsl:include href="kpa-project-bin.xsl"/>
    <xsl:include href="kpa-clips.xsl"/>
    <xsl:include href="kpa-guides.xsl"/>
    <xsl:include href="kpa-track-icons.xsl"/>
    <xsl:include href="kpa-tracks.xsl"/>
    <xsl:include href="kpa-transitions.xsl"/>
    <xsl:include href="kpa-internal-video-compositing.xsl"/>
    <xsl:include href="kpa-internal-audio-mixing.xsl"/>

</xsl:stylesheet>
