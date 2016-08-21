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


    <!-- -->
    <xsl:template name="show-timeline-video-compositing">
        <h3><span class="in-track"><i class="fa fa-clone" aria-hidden="true"/>&#8201;<i class="fa fa-film" aria-hidden="true"/></span> Video Compositing</h3>

        <p>For automatic video track compositing, Kdenlives creates the following compositing transitions automatically behind the scenes.</p>

        <xsl:call-template name="show-timeline-compositing-info"/>

        <!-- Sanity check to quickly identify slightly insane Kdenlive projects -->
        <xsl:if test="not($timeline-compositing-mode = 'none') and ($num-timeline-av-tracks &lt; $num-internally-added-compositing-transitions)">
            <p><xsl:call-template name="warning-icon"/><span class="warning">Warning: </span>found <i>more</i> internally added video compositing transitions (<xsl:value-of select="$num-internally-added-compositing-transitions"/>) than actual video tracks (<xsl:value-of select="$num-timeline-av-tracks"/>) in project &#8211; this project may need some
                <xsl:if test="($num-internally-added-mix-transitions - $num-timeline-av-tracks) &gt; 1">
                    <xsl:text> </xsl:text><b>serious</b>
                </xsl:if>
                <xsl:text> </xsl:text>XML cleanup.</p>
        </xsl:if>

        <xsl:if test="not($timeline-compositing-mode = 'none') and ($num-timeline-av-tracks - 1 &gt; $num-internally-added-compositing-transitions)">
            <p><xsl:call-template name="warning-icon"/><span class="warning">Warning: </span>not enough internally-added video compositing transitions found; there are more tracks (<xsl:value-of select="$num-timeline-av-tracks"/>, not counting the lowest video track) than video compositors (<xsl:value-of select="$num-internally-added-compositing-transitions"/>) in project &#8211; this project need its internally added mix transitions <b>rebuilt</b>, as audio mixing is currently incorrect.</p>
        </xsl:if>

        <p>
            <xsl:value-of select="$num-internally-added-compositing-transitions"/> internally added automatic compositing transitions.
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
                    <xsl:variable name="track-comp-transitions" select="$internally-added-compositing-transitions[number(property[@name='b_track']) = $mlt-track-idx]"/>
                    <xsl:variable name="class">
                        <xsl:choose>
                            <xsl:when test="($mlt-track-idx &lt;= $timeline-lowest-video-track) and (count($track-comp-transitions) = 0)">anno</xsl:when>
                            <xsl:when test="(($mlt-track-idx &lt;= $timeline-lowest-video-track) and (count($track-comp-transitions) &gt; 0)) or (($mlt-track-idx &gt; $timeline-lowest-video-track) and (count($track-comp-transitions) != 1))">error</xsl:when>
                            <xsl:otherwise></xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <span class="{$class}">
                        <xsl:if test="not($timeline-compositing-mode = 'none') and ($mlt-track-idx &gt; $timeline-lowest-video-track)">
                             <i class="fa fa-film" aria-hidden="true" title="internally added compositing transition"/>
                        </xsl:if>
                        <xsl:if test="not($timeline-compositing-mode = 'none') and (count($track-comp-transitions) = 0) and ($mlt-track-idx &gt; $timeline-lowest-video-track)">
                            &#160;<xsl:call-template name="error-icon"/>&#160;missing video compositor
                        </xsl:if>
                        <xsl:if test="($mlt-track-idx &lt;= $timeline-lowest-video-track) and (count($track-comp-transitions) &gt; 0)">
                            &#160;<xsl:call-template name="error-icon"/>&#160;unneeded video compositor
                        </xsl:if>
                    </span>
                    &#160;

                    <xsl:if test="($timeline-compositing-mode = 'track') and ($mlt-track-idx &gt; $timeline-lowest-video-track)">
                        <span class="{$class}">
                            <xsl:call-template name="show-track-state-transparent">
                                <xsl:with-param name="mlt-track-idx" select="$mlt-track-idx"/>
                                <xsl:with-param name="class" select="''"/>
                            </xsl:call-template>
                        </span>
                    </xsl:if>

                    <!-- There should be only one... -->
                    <xsl:if test="count($track-comp-transitions) &gt; 0">
                        <span class="{$class} anno">
                            <xsl:for-each select="$track-comp-transitions">
                                <xsl:variable name="a-track-idx" select="number(property[@name='a_track'])"/>

                                (<i style="white-space: nowrap;"><!--

                                --><xsl:if test="position() &gt; 1">needless </xsl:if><!--

                                --><span title="transition id">"<xsl:value-of select="@id"/>"</span>,

                                <span title="MLT track indices">B/A: <xsl:value-of select="$mlt-track-idx"/>/<xsl:if test="$a-track-idx != $timeline-lowest-video-track">
                                        <xsl:call-template name="error-icon"/><span class="error"><xsl:value-of select="$a-track-idx"/></span>
                                    </xsl:if><xsl:if test="$a-track-idx = $timeline-lowest-video-track">
                                        <xsl:value-of select="$a-track-idx"/>
                                    </xsl:if>
                                </span>,

                                <span title="transition type">type: <xsl:value-of select="property[@name='mlt_service']"/></span></i>)
                            </xsl:for-each>
                            </span>
                    </xsl:if>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>


</xsl:stylesheet>
