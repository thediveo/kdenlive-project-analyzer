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


    <!-- Kdenlive's audio mixing happens in the background by adding the required
         MLT mix transitions.
      -->
    <xsl:template name="show-timeline-audio-mixing">
        <h3><span class="in-track"><i class="fa fa-clone" aria-hidden="true"/>&#8201;<i class="fa fa-volume-up" aria-hidden="true"/></span> Audio Mixing</h3>

        <p>For automatic audio mixing, Kdenlive creates the following mix transitions automatically behind the scenes. These mix transitions get updated by Kdenlive only when adding or removing tracks. They don't get automatically refreshed when loading a project (at least not at this time), so be careful in case they got out of sync.</p>

        <!-- Sanity check to quickly identify slightly insane Kdenlive projects -->
        <xsl:if test="$num-timeline-user-tracks &lt; $num-internally-added-mix-transitions">
            <p><xsl:call-template name="warning-icon"/><span class="warning">Warning: </span>found <i>more</i> internally added audio mix transitions (<xsl:value-of select="$num-internally-added-mix-transitions"/>) than actual tracks (<xsl:value-of select="$num-timeline-user-tracks"/>) in project &#8211; this project may need some
                <xsl:if test="($num-internally-added-mix-transitions - $num-timeline-user-tracks) &gt; 1">
                    <xsl:text> </xsl:text><b>serious</b>
                </xsl:if>
                <xsl:text> </xsl:text>XML cleanup.</p>
        </xsl:if>

        <xsl:if test="$num-timeline-user-tracks &gt; $num-internally-added-mix-transitions">
            <p><xsl:call-template name="warning-icon"/><span class="warning">Warning: </span>not enough internally-added audio mix transitions found; there are more tracks (<xsl:value-of select="$num-timeline-user-tracks"/>) than audio mixers (<xsl:value-of select="$num-internally-added-mix-transitions"/>) in project &#8211; this project need its internally added mix transitions <b>rebuilt</b>, as audio mixing is currently incorrect.</p>
        </xsl:if>

        <p>
            <xsl:if test="$num-timeline-user-tracks != $num-internally-added-mix-transitions">
                <xsl:call-template name="warning-icon"/><span class="warning">Warning: </span>
            </xsl:if>
            <xsl:value-of select="$num-internally-added-mix-transitions"/> internally added <i>mix</i> transitions (for <xsl:value-of select="$num-timeline-user-tracks"/>+1 tracks):
        </p>

        <ul class="tracks">
            <xsl:for-each select="$timeline-tracks">
                <!-- We only need this loop for counting MLT track indices...! -->
                <xsl:variable name="mlt-track-idx" select="$num-timeline-tracks - position()"/>

                <li>
                    <xsl:call-template name="show-track-icon">
                        <xsl:with-param name="mlt-track-idx" select="$mlt-track-idx"/>
                    </xsl:call-template>

                    <xsl:call-template name="show-track-title">
                        <xsl:with-param name="mlt-track-idx" select="$mlt-track-idx"/>
                    </xsl:call-template>

                    <!-- Are there any mix transitions whose B track covers the current
                         track? And how many of them...?
                      -->
                    <xsl:variable name="track-mixer-transitions" select="$internally-added-mix-transitions[number(property[@name='b_track']) = $mlt-track-idx]"/>
                    <xsl:variable name="class">
                        <xsl:choose>
                            <xsl:when test="$mlt-track-idx = 0">anno</xsl:when>
                            <xsl:when test="($mlt-track-idx &gt; 0) and (count($track-mixer-transitions) != 1)">error</xsl:when>
                            <xsl:otherwise></xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <span class="{$class}">
                        <xsl:if test="$mlt-track-idx &gt; 0">
                            <i class="fa fa-volume-up" aria-hidden="true" title="internally added mixing transition"/>
                        </xsl:if>
                        <xsl:if test="(count($track-mixer-transitions) = 0) and ($mlt-track-idx &gt; 0)">
                            &#160;<xsl:call-template name="error-icon"/>&#160;missing audio mixer
                        </xsl:if>
                    </span>
                    &#160;

                    <!-- There really should be only one (mixer) ... per track. -->
                    <xsl:if test="count($track-mixer-transitions) &gt; 0">
                        <span class="{$class} anno">
                            <xsl:for-each select="$track-mixer-transitions">
                                <xsl:variable name="a-track-idx" select="number(property[@name='a_track'])"/>

                                (<i style="white-space: nowrap;"><!--

                                --><xsl:if test="position() &gt; 1"><xsl:call-template name="error-icon"/>&#160;needless </xsl:if><!--

                                --><span title="transition id">"<xsl:value-of select="@id"/>"</span>,
                                <span title="MLT track indices">B/A:
                                    <xsl:value-of select="$mlt-track-idx"/>/<!--
                                    --><xsl:choose>
                                        <xsl:when test="$a-track-idx != 0">
                                            <xsl:call-template name="error-icon"/>&#160;<span class="error"><xsl:value-of select="$a-track-idx"/> instead of 0</span>
                                        </xsl:when>
                                        <xsl:otherwise>0</xsl:otherwise>
                                    </xsl:choose>
                                </span></i>)
                            </xsl:for-each>
                            </span>
                    </xsl:if>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>


</xsl:stylesheet>
