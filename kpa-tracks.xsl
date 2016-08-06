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
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:kpa="http://kdenlive.org/kpa">


    <!-- Show the title of a specific track, given only its (MLT) track index.

         Parameters:
         * mlt-track-idx: the (MLT) track index, where 0 is the black track.
         * class: (optional) if set, the CSS class string to use for wrapping the
             track title into an HTML span element. If left unspecified, then
             the default is to use the CSS class "track-title".
      -->
    <xsl:template name="show-track-title">
        <xsl:param name="mlt-track-idx"/>
        <xsl:param name="class" select="'track-title'"/>

        <!-- Remember: MLT track indices are 0-based, while XPath indices instead
             are 1-based!
          -->
        <xsl:variable name="track-id"
                      select="$timeline-tracks[$mlt-track-idx + 1]/@producer"/>
        <xsl:variable name="track" select="/mlt/playlist[@id = $track-id]"/>

        <!-- Watch the builtin nameless, but not @id-less, "Black" track: we need
             to handle it separately, as it has no name. We thus give it our own
             neat descriptive title.
          -->
        <xsl:choose>
            <!-- it's a user named track, which we detect by the presence of
                 Kdenlive's tack_name property inside a track/playlist element.
              -->
            <xsl:when test="$track/property[@name='kdenlive:track_name']">
                <!-- Show the user-visible, and user-assigned track name -->
                <span class="{$class}">
                    <b><xsl:value-of select="$track/property[@name='kdenlive:track_name']"/></b>
                </span>
            </xsl:when>
            <!-- It's the unnamed (internal) track "black". We thus supply our
                 own descriptive title in spite of a project-given track title.
                 Ordinary Kdenlive users don't get to see this track in the
                 timeline, but will notice it as the bottommost track than can
                 be chosen as the "track" property of Kdenlive's transitions.
              -->
            <xsl:otherwise>
                <span class="{$class} anno"><i>hidden built-in "<b>Black</b>" track</i></span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- Show a track's lock/unlock state in form of an icon. The specific
         icons to be used are defined in a separate module kpa-icons.xsl.

         Parameters:
          * mlt-track-idx: the (MLT) track index, where 0 is the black track.
     -->
    <xsl:template name="show-track-state-locked">
        <xsl:param name="mlt-track-idx"/>

        <!-- Remember: MLT track indices are 0-based, while XPath indices instead
             are 1-based!
          -->
        <xsl:variable name="track-id"
                      select="$timeline-tracks[$mlt-track-idx + 1]/@producer"/>
        <xsl:variable name="track" select="/mlt/playlist[@id = $track-id]"/>

        <!-- Locked? This is decided on the basis of the Kdenlive-defined
             "locked_track" property inside a track/playlist element.
          -->
        <xsl:choose>
            <xsl:when test="$track/property[@name='kdenlive:locked_track'] = '1'">
                <i class="fix-fa fa fa-lock anno-locked" aria-hidden="true" title="locked"/>
            </xsl:when>
            <xsl:otherwise>
                <i class="fix-fa fa fa-unlock anno-unlocked" aria-hidden="true" title="unlocked"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- Show a track's visible/hidden state in form of an icon. The specific
         icons to be used are defined in a separate module kpa-icons.xsl.

         Please note that we gracefully handle the situation where we are
         dealing with an audio-only track: in this case, just a spacer is
         output instead of a visible/hidden state icon.

         Parameters:
          * mlt-track-idx: the (MLT) track index, where 0 is the black track.
    -->
    <xsl:template name="show-track-state-hidden">
        <xsl:param name="mlt-track-idx"/>

        <!-- Remember: MLT track indices are 0-based, while XPath indices instead
             are 1-based!
          -->
        <xsl:variable name="track-ref" select="$timeline-tracks[$mlt-track-idx + 1]"/>
        <xsl:variable name="hide" select="$track-ref/@hide"/>
        <xsl:variable name="track" select="/mlt/playlist[@id = $track-ref/@producer]"/>

        <!-- Hidden video? -->
        <xsl:choose>
            <!-- The hidden/visible state does not apply to audio-only tracks.
                 For audio-only tracks we simply output a spacer instead of any
                 state icon.
              -->
            <xsl:when test="$track/property[@name='kdenlive:audio_track']">
                <!-- show spacer with a fixed space instead of any icon -->
                <span class="fix-fa">&#160;</span>
            </xsl:when>
            <!-- So we're dealing with an audio/video track now... -->
            <xsl:otherwise>
                <xsl:choose>
                    <!-- MLT, and thus Kdenlive in turn, does not define separate
                         hiding/muting attributes, but instead combines both into
                         a single "hide" attribut. So we need to check for multiple
                         combinations where video is hidden.
                      -->
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


    <!-- Show a track's muted/audible state in form of an icon. The specific
         icons to be used are defined in a separate module kpa-icons.xsl.

         Parameters:
          * mlt-track-idx: the (MLT) track index, where 0 is the black track.
    -->
    <xsl:template name="show-track-state-muted">
        <xsl:param name="mlt-track-idx"/>

         <!-- Remember: MLT track indices are 0-based, while XPath indices instead
             are 1-based!
          -->
       <xsl:variable name="track-ref" select="$timeline-tracks[$mlt-track-idx+1]"/>
        <xsl:variable name="hide" select="$track-ref/@hide"/>
        <xsl:variable name="track" select="/mlt/playlist[@id=$track-ref/@producer]"/>

        <!-- Muted? -->
        <xsl:choose>
          <!-- MLT, and thus Kdenlive in turn, does not define separate
             hiding/muting attributes, but instead combines both into
             a single "hide" attribut. So we need to check for multiple
             combinations where audio is muted.
          -->
          <xsl:when test="$hide='audio' or $hide='both'">
                <span class="fix-fa anno-muted" aria-hidden="true" title="muted"><i class="fa fa-volume-off"/>&#215;</span>&#160;
            </xsl:when>
            <xsl:otherwise>
                <i class="fix-fa fa fa-volume-up anno-audible" aria-hidden="true" title="audible"/>&#160;
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- Show a track's compositing state (transparent/opaque) in form of
         an icon. The specific icons to be used are defined in a separate
         module kpa-icons.xsl.

         Parameters:
          * mlt-track-idx: the (MLT) track index, where 0 is the black track.
          * class: (optional) if set, the CSS class string to use for wrapping the
             compositing state indication into an HTML span element. If left
             unspecified, then the default is to use the CSS class "fix-fa".
   -->
    <xsl:template name="show-track-state-transparent">
        <xsl:param name="mlt-track-idx"/>
        <xsl:param name="class" select="fix-fa"/>

        <!-- Remember: MLT track indices are 0-based, while XPath indices instead
             are 1-based!
          -->
        <xsl:variable name="track-id"
                      select="$timeline-tracks[$mlt-track-idx + 1]/@producer"/>
        <xsl:variable name="track" select="/mlt/playlist[@id = $track-id]"/>

       <!-- Video track compositing? -->
        <xsl:choose>
            <!-- In case of audio-only tracks we simply output a spacer instead
                 of a compositing state icon.
              -->
            <xsl:when test="$track/property[@name='kdenlive:audio_track']">
                <!-- show spacer -->
                <span class="{$class}">&#160;</span>
            </xsl:when>
            <!-- We're dealing with an audio/video track. The difficult part now
                 is that Kdenlive over time had different ways of how transparent
                 tracks are configured/signalled. We basically today have:
                 1. no track transparency at all - this is to be assumed whenever
                    we don't find any internally added compositing transitions in
                    the main tractor.
                    a. pre 15.08 or so.
                    b. 16.08+ with timeline compositing set to "none".
                 2. track-wise transparency (15.08 to 16.04) - this can be easily
                    detected through Kdenlive-specific "composite" properties inside
                    the track/playlist elements.
                 3. timeline compositing (16.04+) - this can be detected from the
                    type of internally added compositing transitions used, as well as
                    from the absence of any Kdenlive-specific track-wise "composite"
                    properties inside the track/playlist elements. There are currently
                    these two qualities for timeline compositing available:
                    a. "preview" mode
                    b. "high quality" mode
              -->
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


    <xsl:template name="show-track-transitions-end">
        <xsl:param name="mlt-track-idx"/>

        <xsl:call-template name="show-timecode">
            <xsl:with-param name="frames">
                <xsl:call-template name="calc-track-transitions-end">
                    <xsl:with-param name="mlt-track-idx" select="$mlt-track-idx"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <xsl:template name="track-total-length-timecode">
        <xsl:param name="mlt-track-idx"/>

        <xsl:variable name="len-by-clip">
            <xsl:call-template name="calc-track-length">
                <xsl:with-param name="mlt-track-idx" select="$mlt-track-idx"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="len-by-transition">
            <xsl:call-template name="calc-track-transitions-end">
                <xsl:with-param name="mlt-track-idx" select="$mlt-track-idx"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$len-by-clip &gt;= $len-by-transition">
                <span title="track length, determinded by last clip">
                    <xsl:call-template name="show-timecode">
                        <xsl:with-param name="frames">
                            <xsl:value-of select="$len-by-clip"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span title="track length, as determined by overhanging transition">
                    <xsl:call-template name="show-timecode">
                        <xsl:with-param name="frames">
                            <xsl:value-of select="$len-by-transition"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- Spacer for -->
    <xsl:template name="show-track-state-spacer">
        <span class="fix-fa"/>
    </xsl:template>


    <!-- List all the (timeline) tracks that are defined in this Kdenlive project.
         We list/show the tracks in the usual Kdenlive timeline layout, that is,
         from the topmost track down to the bottommost track, in this order. On
         purpose, we list *all* tracks, including the built-in and hidden "Black"
         track that Kdenlive automatically includes with each project.
      -->
    <xsl:template name="list-all-tracks">
        <!-- Kdenlive's tracks are referenced as <tracks> elements inside the
             main <tractor> with id "maintractor". However, the Kdenlive
             tracks themselves are then represented as <playlists>. -->
        <xsl:if test="count(/mlt/playlist[@id='black_track']) != 1">
            <xsl:call-template name="error-icon"/>&#160;The hidden built-in internal "Black" track is missing.
        </xsl:if>

        <xsl:call-template name="show-timeline-compositing-info"/>

        <p><xsl:value-of select="$num-timeline-user-tracks"/> <span class="anno"> (<i>+1 hidden built-in "Black" track</i>)</span> timeline tracks:</p>
        <ul class="tracks">
            <xsl:for-each select="$timeline-tracks">
                <!-- We only need this loop for counting MLT track indices...! -->
                <li>
                    <xsl:call-template name="show-track-info">
                        <xsl:with-param name="mlt-track-idx" select="$num-timeline-tracks - position()"/>
                    </xsl:call-template>
                </li>
            </xsl:for-each>
        </ul>

        <!-- Check the hidden built-in black track #0 to match the overall
             timeline length as calculated on the basis of all user tracks,
             with indices from #1 on.
          -->
        <xsl:variable name="black-track-len">
            <xsl:call-template name="calc-track-length">
                <xsl:with-param name="mlt-track-idx" select="0"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="timeline-len">
            <xsl:call-template name="max-timeline-length"/>
        </xsl:variable>

        <p>
            The overall timeline length is
            <xsl:call-template name="show-timecode">
                <xsl:with-param name="frames">
                    <xsl:value-of select="$timeline-len"/>
                </xsl:with-param>
            </xsl:call-template>.
        </p>

        <p class="anno">
            (<i>Please note that for projects edited with Kdenlive 16.07.xx, 16.08, or later, the hidden built-in "Black" track is always one frame longer than the overall timeline length. The calculation of the overall timeline length is only taking user-visible timeline tracks into the overall length calculation. For older projects, the length of the "Black" tracks equals that of the overall timeline length.</i>)
        </p>

        <xsl:if test="($timeline-len != $black-track-len) and ($timeline-len != ($black-track-len - 1))">
            <xsl:call-template name="error-icon"/>&#160;
            <span class="error">
                Error: the hidden built-in "Black" track (<xsl:call-template name="show-timecode"><xsl:with-param name="frames" select="$black-track-len"/></xsl:call-template>) is
                <xsl:choose>
                    <!-- The black track actually seems to be always one frame longer
                         than the overall timeline length; probably so users can
                         add or insert clips at the end after the last clip?
                      -->
                    <xsl:when test="$timeline-len &gt; ($black-track-len - 1)">
                        shorter
                    </xsl:when>
                    <xsl:otherwise>
                        longer
                    </xsl:otherwise>
                </xsl:choose>
                than the overall timeline length (<xsl:call-template name="show-timecode"><xsl:with-param name="frames" select="$timeline-len"/></xsl:call-template>)!
            </span>
        </xsl:if>

        <p>
            The bottommost <i>video</i> track is track
            "<xsl:call-template name="show-track-title">
                <xsl:with-param name="mlt-track-idx" select="$timeline-lowest-video-track"/>
                <xsl:with-param name="class" select="''"/>
            </xsl:call-template>"
            <span class="anno">(<i>MLT track index: <xsl:value-of select="$timeline-lowest-video-track"/></i>)</span>
        </p>
    </xsl:template>


    <!-- Calculate total length of a track in frames, based on clips -->
    <xsl:template name="calc-track-length">
        <xsl:param name="mlt-track-idx"/>

        <xsl:variable name="track-ref" select="$timeline-tracks[$mlt-track-idx+1]/@producer"/>
        <xsl:variable name="track-playlist" select="/mlt/playlist[@id=$track-ref]"/>
        <xsl:variable name="clips" select="$track-playlist/entry"/>

        <xsl:variable name="s" select="sum($track-playlist/blank/@length)"/>
        <xsl:variable name="i" select="sum($clips/@in)"/>
        <xsl:variable name="o" select="sum($clips/@out)"/>
        <!-- clip/entry lengths are actually out-in+1, so we need to correct the
             sums calculated from outs-ins...
          -->
        <xsl:variable name="c" select="count($clips)"/>
        <xsl:value-of select="($o - $i) + $c + $s"/>
    </xsl:template>


    <!-- Render track properties, such as track type, name, hidden, locked, muted,
         compositing, et cetera.

         Parameters:
         * track-idx: the 0-based (MLT) track index
      -->
    <xsl:template name="show-track-info">
        <xsl:param name="mlt-track-idx"/>

        <xsl:variable name="track-ref" select="$timeline-tracks[$mlt-track-idx+1]/@producer"/>
        <xsl:variable name="track-playlist" select="/mlt/playlist[@id=$track-ref]"/>

        <xsl:call-template name="show-track-icon">
            <xsl:with-param name="mlt-track-idx" select="$mlt-track-idx"/>
        </xsl:call-template>

        <xsl:call-template name="show-track-title">
            <xsl:with-param name="mlt-track-idx" select="$mlt-track-idx"/>
        </xsl:call-template>

        <span class="track-states">
            <xsl:call-template name="show-track-state-locked">
                <xsl:with-param name="mlt-track-idx" select="$mlt-track-idx"/>
            </xsl:call-template>

            <xsl:call-template name="show-track-state-muted">
                <xsl:with-param name="mlt-track-idx" select="$mlt-track-idx"/>
            </xsl:call-template>

            <xsl:call-template name="show-track-state-hidden">
                <xsl:with-param name="mlt-track-idx" select="$mlt-track-idx"/>
            </xsl:call-template>

            <xsl:call-template name="show-track-state-transparent">
                <xsl:with-param name="mlt-track-idx" select="$mlt-track-idx"/>
            </xsl:call-template>

            <xsl:call-template name="show-track-state-effects">
                <xsl:with-param name="mlt-track-idx" select="$mlt-track-idx"/>
            </xsl:call-template>
        </span>

        <!-- calculate total track length on the basis of clips and
             transitions
          -->
        <span class="track-length">
            <xsl:call-template name="track-total-length-timecode">
                <xsl:with-param name="mlt-track-idx" select="$mlt-track-idx"/>
            </xsl:call-template>
        </span>

        <!-- internal information -->
        <span class="anno-id"> (<i>track id: "<xsl:value-of select="$track-ref"/>", index: <xsl:value-of select="$mlt-track-idx"/></i>)</span>
    </xsl:template>



</xsl:stylesheet>
