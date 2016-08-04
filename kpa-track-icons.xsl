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


    <!-- generic video track icon -->
    <xsl:template name="video-track-icon">
        <xsl:param name="title" select="'video track'"/>
        <i class="fa fa-film in-track" title="{$title}"/>
    </xsl:template>


    <!-- generic audio track icon -->
    <xsl:template name="audio-track-icon">
        <xsl:param name="title" select="'audio track'"/>
        <i class="fa fa-volume-up in-track" title="{$title}"/>
    </xsl:template>


    <!-- Show transparent track state icon -->
    <xsl:template name="transparent-track-icon">
        <i class="fa fa-delicious anno-composite" aria-hidden="true" title="transparent track"/>&#160;
    </xsl:template>


    <!-- Show opaque track state icon -->
    <xsl:template name="opaque-track-icon">
        <i class="fa fa-square-o anno-opaque" aria-hidden="true" title="opaque track"/>&#160;
    </xsl:template>


    <!-- Show appropriate icon depending on type of track.
      -->
    <xsl:template name="show-track-icon">
        <xsl:param name="mlt-track-idx"/>

        <xsl:variable name="track-ref" select="$timeline-tracks[$mlt-track-idx+1]"/>
        <xsl:variable name="hide" select="$track-ref/@hide"/>
        <xsl:variable name="track" select="/mlt/playlist[@id=$track-ref/@producer]"/>

        <!-- Watch the builtin nameless, but not @id-less "Black" track!
          -->
        <xsl:choose>
            <!-- a user named track -->
            <xsl:when test="$track/property[@name='kdenlive:track_name']">
                <!-- Track type icon: video or audio; this information is found inside the
                     <playlist> track element.
                  -->
                <span class="track-icon">
                    <xsl:choose>
                        <xsl:when test="$track/property[@name='kdenlive:audio_track']">
                            <xsl:call-template name="audio-track-icon"><xsl:with-param name="title" select="concat('audio track no. ', $mlt-track-idx)"/></xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="video-track-icon"><xsl:with-param name="title" select="concat('video track no. ', $mlt-track-idx)"/></xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </xsl:when>
            <!-- an unnamed (internal) track -->
            <xsl:otherwise>
                <span class="track-icon anno" aria-hidden="true" title="builtin &#34;Black&#34; track"><i class="fa fa-eye-slash in-track"/></span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


</xsl:stylesheet>
