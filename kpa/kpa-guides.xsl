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


    <!-- Gather all timeline guides. Guides are stored inside the main bin
         as properties whose names start with "kdenlive:guide.". Following
         this prefix is a locale-based double that specifies the timeline
         position of the guide, in seconds - but not frames! Finally, the
         textual content is the descriptive title of the guide.
      -->
    <xsl:variable name="timeline-guides"
                  select="/mlt/playlist[@id='main bin']/property[starts-with(@name,'kdenlive:guide.')]"/>
    <xsl:variable name="num-timeline-guides" select="count($timeline-guides)"/>


    <!-- List all timeline guides, with their names and positions. The positions
         are given as timecodes.
      -->
    <xsl:template name="list-all-guides">
        <p><xsl:value-of select="$num-timeline-guides"/> timeline guides:</p>

        <xsl:variable name="fps" select="round(/mlt/profile/@frame_rate_num div /mlt/profile/@frame_rate_den)"/>

        <ul class="guides">
            <xsl:for-each select="$timeline-guides">
                <!-- Kdenlive stores guide positions not in frames, but instead as
                     seconds and fractions (but not frames!) thereof. Of course,
                     this floating point number is represented according to the
                     locale indicated at the top-level mlt element. Sigh. So the
                     following is a hack that assumes that decimal marks can only be
                     "." or ",", and that no thousands separators are present - which
                     aren't, luckily.
                  -->
                <!-- Wikipedia: "The 22nd General Conference on Weights and Measures declared
                     in 2003 that "the symbol for the decimal marker shall be either the point
                     on the line or the comma on the line".
                     cf: https://en.wikipedia.org/wiki/Decimal_mark
                  -->
                <xsl:variable name="guide-pos" select="number(translate(substring-after(@name, 'kdenlive:guide.'), ',', '.'))"/>
                <li>
                    <i class="fa fa-flag"/>&#160;
                    <b><xsl:value-of select="."/></b>:
                    <i>at:</i>&#160;
                    <xsl:call-template name="show-timecode">
                        <xsl:with-param name="frames" select="$guide-pos * $fps"/>
                    </xsl:call-template>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>


</xsl:stylesheet>
