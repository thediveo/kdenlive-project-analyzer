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


    <!-- Render a description with a value/selector in form of a table row
         consisting of exactly two columns: the left column/cell receives
         a description text, while the right column receives a value.

         Parameters:
         * description: (prefered if specified) the text to output into
             left cell. This parameter allows for only for pure text
             descriptions, without any markup.
         * description-copy: (optional) the node set to copy into the
             description/left cell. Use this parameter when your description
             contains markup that needs to be copied into the analyzer output.
         * text: (preferred if specified) the value (text) to output into
             the right cell. Again, this parameter allows only for pure text
             values without any markup.
         * copy: (optional) the node set to copy into the right cell, when a
             value consists of markup.
      -->
    <xsl:template name="show-description-with-value">
        <xsl:param name="description"/>
        <xsl:param name="description-copy"/>
        <xsl:param name="text"/>
        <xsl:param name="copy"/>
        <tr>
            <td>
                <xsl:choose>
                    <xsl:when test="$description"><xsl:value-of select="$description"/></xsl:when>
                    <xsl:otherwise><xsl:copy-of select="$description-copy"/></xsl:otherwise>
                </xsl:choose>
                </td>
            <td>
                <xsl:choose>
                    <xsl:when test="$text"><xsl:value-of select="$text"/></xsl:when>
                    <xsl:otherwise><xsl:copy-of select="$copy"/></xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>


    <!-- -->
    <xsl:template name="show-timecode">
        <xsl:param name="frames"/>

        <xsl:variable name="fps" select="round(/mlt/profile/@frame_rate_num div /mlt/profile/@frame_rate_den)"/>

        <xsl:variable name="ff" select="format-number($frames mod $fps, '00')"/>
        <xsl:variable name="ss" select="format-number(floor($frames div $fps) mod 60, '00')"/>
        <xsl:variable name="mm" select="format-number(floor(($frames div $fps) div 60) mod 60, '00')"/>
        <xsl:variable name="hh" select="format-number(floor(($frames div $fps) div 3600), '00')"/>

        <tt><xsl:value-of select="$hh"/>:<xsl:value-of select="$mm"/>:<xsl:value-of select="$ss"/>:<xsl:value-of select="$ff"/></tt>
        <!--(<xsl:value-of select="$frames"/>)-->
    </xsl:template>


</xsl:stylesheet>
