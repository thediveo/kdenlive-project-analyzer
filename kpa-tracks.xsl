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


    <!-- Show title of a track.
      -->
    <xsl:template name="show-track-title">
        <xsl:param name="mlt-track-idx"/>
        <xsl:param name="class" select="'track-title'"/>

        <xsl:variable name="track-ref" select="$timeline-tracks[$mlt-track-idx+1]"/>
        <xsl:variable name="track" select="/mlt/playlist[@id=$track-ref/@producer]"/>

        <!-- Watch the builtin nameless, but not @id-less "Black" track!
          -->
        <xsl:choose>
            <!-- a user named track -->
            <xsl:when test="$track/property[@name='kdenlive:track_name']">
                <!-- The user-visible track name -->
                <span class="{$class}">
                    <b><xsl:value-of select="$track/property[@name='kdenlive:track_name']"/></b>
                </span>
            </xsl:when>
            <!-- an unnamed (internal) track -->
            <xsl:otherwise>
                <span class="{$class} anno"><i>hidden built-in "<b>Black</b>" track</i></span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- -->
    <xsl:template name="show-track-state-locked">
        <xsl:param name="mlt-track-idx"/>

        <xsl:variable name="track-ref" select="$timeline-tracks[$mlt-track-idx+1]"/>
        <xsl:variable name="track" select="/mlt/playlist[@id=$track-ref/@producer]"/>

        <!-- Locked? -->
        <xsl:choose>
            <xsl:when test="$track/property[@name='kdenlive:locked_track']=1">
                <i class="fix-fa fa fa-lock anno-locked" aria-hidden="true" title="locked"/>&#160;
            </xsl:when>
            <xsl:otherwise>
                <i class="fix-fa fa fa-unlock anno-unlocked" aria-hidden="true" title="unlocked"/>&#160;
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- -->
    <xsl:template name="show-track-state-hidden">
        <xsl:param name="mlt-track-idx"/>

        <xsl:variable name="track-ref" select="$timeline-tracks[$mlt-track-idx+1]"/>
        <xsl:variable name="hide" select="$track-ref/@hide"/>
        <xsl:variable name="track" select="/mlt/playlist[@id=$track-ref/@producer]"/>

        <!-- Hidden video? -->
        <xsl:choose>
            <xsl:when test="$track/property[@name='kdenlive:audio_track']">
                <!-- show spacer -->
                <span class="fix-fa">&#160;</span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$hide='video' or $hide='both'">
                        <i class="fix-fa fa fa-eye-slash anno-hidden" aria-hidden="true" title="hidden"/>&#160;
                    </xsl:when>
                    <xsl:otherwise>
                        <i class="fix-fa fa fa-eye anno-visible" aria-hidden="true" title="visible"/>&#160;
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- -->
    <xsl:template name="show-track-state-muted">
        <xsl:param name="mlt-track-idx"/>

        <xsl:variable name="track-ref" select="$timeline-tracks[$mlt-track-idx+1]"/>
        <xsl:variable name="hide" select="$track-ref/@hide"/>
        <xsl:variable name="track" select="/mlt/playlist[@id=$track-ref/@producer]"/>

        <!-- Muted? -->
        <xsl:choose>
            <xsl:when test="$hide='audio' or $hide='both'">
                <span class="fix-fa anno-muted" aria-hidden="true" title="muted"><i class="fa fa-volume-off"/>&#215;</span>&#160;
            </xsl:when>
            <xsl:otherwise>
                <i class="fix-fa fa fa-volume-up anno-audible" aria-hidden="true" title="audible"/>&#160;
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- -->
    <xsl:template name="show-track-state-transparent">
        <xsl:param name="mlt-track-idx"/>
        <xsl:param name="class" select="fix-fa"/>

        <xsl:variable name="track-ref" select="$timeline-tracks[$mlt-track-idx+1]"/>
        <xsl:variable name="track" select="/mlt/playlist[@id=$track-ref/@producer]"/>

       <!-- Video track compositing? -->
        <xsl:choose>
            <xsl:when test="$track/property[@name='kdenlive:audio_track']">
                <!-- show spacer -->
                <span class="{$class}">&#160;</span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <!-- this project seems to use old track-wise compositing -->
                    <xsl:when test="$timeline-compositing-mode = 'track'">
                        <!-- automatic composition needs an excplit invitation! -->
                        <xsl:choose>
                            <xsl:when test="$track/@id = 'black_track'">
                                <!-- don't show state icon for built-in track -->
                                <span class="{$class}"/>
                            </xsl:when>
                            <xsl:when test="$track/property[@name='kdenlive:composite']=1">
                                <span class="{$class}"><xsl:call-template name="transparent-track-icon"/></span>
                            </xsl:when>
                            <xsl:otherwise>
                                <span class="{$class}"><xsl:call-template name="opaque-track-icon"/></span>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$timeline-compositing-mode = 'none'">
                        <!-- none: we show no compositing state/control icon then -->
                        <!-- show spacer instead -->
                        <span class="{$class}">&#160;</span>
                    </xsl:when>
                    <!-- new timeline-wise track compositing modes -->
                    <xsl:otherwise>
                        <span class="{$class}"><xsl:call-template name="transparent-track-icon"/></span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- -->
    <xsl:template name="show-track-state-effects">
        <xsl:param name="mlt-track-idx"/>

        <xsl:variable name="track-ref" select="$timeline-tracks[$mlt-track-idx+1]"/>
        <xsl:variable name="track-playlist" select="/mlt/playlist[@id=$track-ref/@producer]"/>

        <xsl:choose>
            <xsl:when test="$mlt-track-idx &gt; 0">
                <!-- Placeholder for now -->
                <span class="fix-fa"><i class="fa fa-star-o anno"/></span>
            </xsl:when>
            <xsl:otherwise>
                <!-- Spacer -->
                <span class="fix-fa">&#160;</span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


</xsl:stylesheet>
