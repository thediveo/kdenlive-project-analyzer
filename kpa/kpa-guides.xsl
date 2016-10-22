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


    <!-- Gather all timeline guides.
      -->
    <xsl:variable name="timeline-guides"
                  select="/mlt/playlist[@id='main bin']/property[starts-with(@name,'kdenlive:guide.')]"/>
    <xsl:variable name="num-timeline-guides" select="count($timeline-guides)"/>


    <!-- List all timeline guides, with their names and positions.
      -->
    <xsl:template name="list-all-guides">
        <p><xsl:value-of select="$num-timeline-guides"/> timeline guides:</p>

        <ul>
            <xsl:for-each select="$timeline-guides">
                <li>
                    <b><xsl:value-of select="."/></b>:
                    at <xsl:value-of select="substring-after(@name, 'kdenlive:guide.')"/>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>

</xsl:stylesheet>
