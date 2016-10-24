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


    <!-- Heuristics for finding out which flavor of transparent tracks are used in
         a Kdenlive project.

         Please note that for old track-wise projects the compositing transitions
         are only present for the tracks for which automatic compositing is enabled,
         that is, only for "transparent tracks". However, these tracks may be
         still set to "opaque" by disabling the corresponding internally-added
         compositing transition.

         These heuristics may totally mess up when the internally added
         transitions are totally messed up. No wonder.

         Possible values are:
         * "none": no suitable information about compositing found
         * "track": old track-wise controllable compositing
         * "preview": new timeline-wise preview-quality compositing
         * "hq": new timeline-wise high-quality compositing
      -->
    <xsl:variable name="timeline-compositing-mode">
        <xsl:choose>
            <xsl:when test="$num-internally-added-compositing-transitions &gt; 0">
                <xsl:variable name="compositor-type" select="$internally-added-compositing-transitions[1]/property[@name='mlt_service']/text()"/>
                <xsl:choose>
                    <xsl:when test="$compositor-type = 'qtblend'">hq</xsl:when>
                    <xsl:when test="$compositor-type = 'composite'">preview</xsl:when>
                    <xsl:when test="$compositor-type = 'frei0r.cairoblend'">track</xsl:when>
                    <xsl:otherwise>track</xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>none</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>


    <!-- Gather all timeline tracks, and some associated information. This
         later helps us avoiding using the same XPath code over and over
         again, with some subtle bugs between different instances...
      -->
    <!-- All timeline track references from the "maintractor" -->
    <xsl:variable name="timeline-tracks" select="/mlt/tractor[@id='maintractor']/track"/>
    <xsl:variable name="num-timeline-tracks" select="count($timeline-tracks)"/>


    <!-- Only the user-visible timeline track references, excluding Kdenlive's
         internal hidden "black_track" -->
    <xsl:variable name="timeline-user-tracks" select="$timeline-tracks[not(@producer = 'black_track')]"/>
    <xsl:variable name="num-timeline-user-tracks" select="count($timeline-user-tracks)"/>


    <!-- Only the audio/video timeline user track references, excluding audio-only
         tracks.
      -->
    <xsl:variable name="timeline-av-tracks" select="/mlt/playlist[boolean(property[@name='kdenlive:track_name']) and not(property[@name='kdenlive:audio_track'] = '1')]"/>
    <xsl:variable name="num-timeline-av-tracks" select="count($timeline-av-tracks)"/>


    <!-- Audio-only timeline user track references, excluding audio/video tracks.
      -->
    <xsl:variable name="timeline-audio-tracks" select="/mlt/playlist[boolean(property[@name='kdenlive:track_name']) and (property[@name='kdenlive:audio_track'] = '1')]"/>
    <xsl:variable name="num-timeline-audio-tracks" select="count($timeline-audio-tracks)"/>


    <!-- Calculate the overall number of timeline clips. This involves
         iterating over all timeline (user) tracks and then counting all
         clip/producer referenced on each track.

         Thanks to XPath 2.0 this has become so much easier; no more
         recursive template required in order to iterate over all tracks,
         summing up the track-wise clip counts. Phew!
      -->
    <xsl:variable name="num-timeline-clips"
                  select="sum(for $t in $timeline-user-tracks return count(/mlt/playlist[@id=$t/@producer]/entry))">
    </xsl:variable>


    <!-- Show a short report sentence about the (sometimes only assumed)
         timeline compositing mode.
      -->
    <xsl:template name="show-timeline-compositing-info">
        <p>The timeline track compositing is
            <xsl:choose>
                <xsl:when test="$timeline-compositing-mode = 'none'">
                    completely <i>off</i>.
                </xsl:when>
                <xsl:when test="$timeline-compositing-mode = 'track'">
                    (old) <i>track-wise</i> controllable.
                </xsl:when>
                <xsl:when test="$timeline-compositing-mode = 'preview'">
                    <i>preview quality</i>.
                </xsl:when>
                <xsl:when test="$timeline-compositing-mode = 'hq'">
                    <i>high quality</i>.
                </xsl:when>
            </xsl:choose>
        </p>
    </xsl:template>


    <!-- recursive function for finding the first (bottommost) video track;
         this used to be of importance with the older automatic track compositing.
         Newer track compositing differs slightly in that it now composes all
         video tracks onto the bottom black track, as opposed to compositing all
         video tracks onto the bottommost video track.

         Parameters:
         * mlt-track-idx: the (MLT) track index to check if it's a video track,
                          and otherwise recursing using the next higher track;
                          defaults to 1 (which is the first user-visible timeline
                          track).
      -->
    <xsl:template name="find-lowest-video-track">
        <xsl:param name="mlt-track-idx" select="1"/>

        <!-- Exit recursion if (MLT) track index is beyond topmost track index. -->
        <xsl:if test="$mlt-track-idx &lt; $num-timeline-tracks">
            <xsl:variable name="track-ref" select="$timeline-tracks[$mlt-track-idx+1]"/>
            <xsl:variable name="track" select="/mlt/playlist[@id=$track-ref/@producer]"/>

            <xsl:choose>
                <!-- audio-only track? Then search on and recurse! -->
                <xsl:when test="$track/property[@name='kdenlive:audio_track']">
                    <xsl:call-template name="find-lowest-video-track">
                        <xsl:with-param name="mlt-track-idx" select="$mlt-track-idx + 1"/>
                    </xsl:call-template>
                </xsl:when>
                <!-- we've found a video track, so we can terminate the recursion. -->
                <xsl:otherwise><xsl:value-of select="$mlt-track-idx"/></xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>


    <!-- (Slightly useless) Wrapper around the recursive template for determining
         the lowest video track.
      -->
    <xsl:variable name="timeline-lowest-video-track">
        <xsl:call-template name="find-lowest-video-track"/>
    </xsl:variable>


    <!-- (Recursive) Template for calculating the overall (total) length
         of the timeline.

         Parameters:
         * mlt-track-idx: the (MLT) track index from which to start calculating the
                          overall timeline length; it is used for recursion.
      -->
    <xsl:template name="max-timeline-length">
        <xsl:param name="mlt-track-idx" select="1"/>

        <!-- We are actually more detailed here in calculating the length of a
             specific track: while Kdenlive bases its own calculation solely on
             the space occupied by clips (and blanks inbetween), we also take
             those transitions into consideration that according to their A track
             are "attached" to this specific track.
          -->
        <xsl:variable name="transitions-track-len">
            <xsl:call-template name="calc-track-transitions-end">
                <xsl:with-param name="mlt-track-idx" select="$mlt-track-idx"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="clips-track-len">
            <xsl:call-template name="calc-track-length">
                <xsl:with-param name="mlt-track-idx" select="$mlt-track-idx"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- Calculate the maximum of (transitions length, clips length) for this
             specific track.
          -->
        <xsl:variable name="track-len">
            <xsl:choose>
                <!-- Watch the subtle differences between XSLT 1.0 and 2.0: we cannot
                     be lazy anymore when using the comparism binary operators; we need
                     to tell XSLT here that we need to compare number-wise, but not
                     string-wise.
                  -->
                <xsl:when test="number($clips-track-len) &gt;= number($transitions-track-len)">
                    <xsl:value-of select="$clips-track-len"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$transitions-track-len"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <!-- Check the length of this track against the longest track length of
                 the tracks above this track; so, using recursion.
              -->
            <xsl:when test="number($mlt-track-idx) &lt; number($num-timeline-tracks)">
                <xsl:variable name="maxlen">
                    <xsl:call-template name="max-timeline-length">
                        <xsl:with-param name="mlt-track-idx" select="$mlt-track-idx + 1"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="number($maxlen) &gt; number($track-len)"><xsl:value-of select="$maxlen"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="$track-len"/></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- Terminate recursion, as we've reached the topmost timeline track. -->
            <xsl:otherwise><xsl:value-of select="$track-len"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- Convenience template that outputs the overall (total) timeline length
         in form of a neatly formatted time code.
      -->
    <xsl:template name="show-timeline-length">
        <xsl:call-template name="show-timecode">
            <xsl:with-param name="frames">
                <xsl:call-template name="max-timeline-length"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


</xsl:stylesheet>
