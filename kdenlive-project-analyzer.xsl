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

    <xsl:variable name="version" select="'0.9.9'"/>


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
    <xsl:include href="kpa-track-icons.xsl"/>
    <xsl:include href="kpa-tracks.xsl"/>
    <xsl:include href="kpa-transitions.xsl"/>









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


    <xsl:template name="max-timeline-length">
        <xsl:param name="mlt-track-idx" select="1"/>

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

        <xsl:variable name="len">
            <xsl:choose>
                <xsl:when test="$clips-track-len &gt;= $transitions-track-len">
                    <xsl:value-of select="$clips-track-len"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$transitions-track-len"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$mlt-track-idx &lt; $num-timeline-tracks">
                <xsl:variable name="maxlen">
                    <xsl:call-template name="max-timeline-length">
                        <xsl:with-param name="mlt-track-idx" select="$mlt-track-idx + 1"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$maxlen > $len"><xsl:value-of select="$maxlen"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="$len"/></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="$len"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="show-timeline-length">
        <xsl:call-template name="show-timecode">
            <xsl:with-param name="frames">
                <xsl:call-template name="max-timeline-length"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <!-- Spacer for -->
    <xsl:template name="show-track-state-spacer">
        <span class="fix-fa"/>
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


    <!-- recursive function for finding the first video track -->
    <xsl:template name="find-lowest-video-track">
        <xsl:param name="mlt-track-idx" select="1"/>

        <xsl:if test="$mlt-track-idx &lt; $num-timeline-tracks">
            <xsl:variable name="track-ref" select="$timeline-tracks[$mlt-track-idx+1]"/>
            <xsl:variable name="track" select="/mlt/playlist[@id=$track-ref/@producer]"/>

            <xsl:choose>
                <!-- audio-only track? search on! -->
                <xsl:when test="$track/property[@name='kdenlive:audio_track']">
                    <xsl:call-template name="find-lowest-video-track">
                        <xsl:with-param name="mlt-track-idx" select="$mlt-track-idx + 1"/>
                    </xsl:call-template>
                </xsl:when>
                <!-- try next upper track -->
                <xsl:otherwise><xsl:value-of select="$mlt-track-idx"/></xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>


    <xsl:variable name="timeline-lowest-video-track">
        <xsl:call-template name="find-lowest-video-track"/>
    </xsl:variable>




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


    <!-- Renders a clip icon depending on the clip's type. The following clip icons are
         differentiated:
         * video clip (this is also the fallback in case we don't find a more specific icon)
         * audio-only clip
         * title clip
         * image clip
         * color clip
         * internal/hidden/built-in clip - such as the "black" clip in particular.

         The parameter(s) of this template are as follows:
         * param clipid: the clip id of the <producer> representing the clip. This producer
             encapsulates additional information, depending on the type of clip.

      -->
    <xsl:template name="clip-icon">
        <xsl:param name="clipid"/>
        <xsl:choose>
            <!-- special case: built-in "black" clip -->
            <xsl:when test="$clipid='black'">
                <span class="anno"><i class="fa fa-eye-slash" aria-hidden="true" title="builtin black clip"/>&#160;</span>
            </xsl:when>
            <!-- all other non built-in clips -->
            <xsl:otherwise>
                <!-- what kind of clip do we have here? -->
                <xsl:choose>
                    <!-- audio clip that has no video stream -->
                    <xsl:when test="property[@name='video_index']/text()='-1'">
                        <xsl:call-template name="audio-clip-icon"/>&#160;
                    </xsl:when>
                    <!-- an image clip or clip sequence -->
                    <xsl:when test="property[@name='mlt_service']/text()='pixbuf'">
                        <!-- the difference between a single image and an image sequence
                             can be told from the way the resource property. For image
                             sequences, the resource is specially crafted, starting with
                             .all. instead of a filename.
                          -->
                        <xsl:choose>
                            <xsl:when test="starts-with(replace(property[@name='resource'],'.*/',''),'.all.')">
                                <xsl:call-template name="image-sequence-clip-icon"/>&#160;
                            </xsl:when>
                            <xsl:otherwise>
                                <i class="fa fa-picture-o" aria-hidden="true" title="image clip"/>&#160;
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="property[@name='mlt_service']/text()='qimage'">
                        <xsl:call-template name="image-clip-icon"/>&#160;
                    </xsl:when>
                    <!-- Kdenlive title clip -->
                    <xsl:when test="property[@name='mlt_service']/text()='kdenlivetitle'">
                        <xsl:call-template name="title-clip-icon"/>&#160;
                    </xsl:when>
                    <!-- MLT color clip -->
                    <xsl:when test="property[@name='mlt_service']/text()='color'">
                        <xsl:call-template name="color-clip-icon"/>&#160;
                    </xsl:when>
                    <!-- MLT generators -->
                        <!-- t.b.d. -->
                    <!-- everything else, that is, a video clip (or so we think) -->
                    <xsl:otherwise>
                        <xsl:call-template name="av-clip-icon"/>&#160;
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- -->
    <xsl:template name="list-all-clips">
        <xsl:variable name="folders" select="/mlt/playlist[@id='main bin']/property[starts-with(@name,'kdenlive:folder.')]"/>

        <ul class="project-clips">
            <xsl:for-each select="/mlt/producer">
                <!-- The really messy part here is that we want to sort based on the
                     "names" of the clips. However, if no specific name has been set,
                     then Kdenlive takes the name+ext of a clip without its path as
                     its default name. In our hack to simplify the sorting expression
                     we thus simply concatenate the clip name (which can be empty) with
                     the name+ext of the clip filename.
                  -->
                <xsl:sort select="concat(property[@name='kdenlive:clipname'],replace(property[@name='resource'],'.*/',''),property[@name='resource'])" data-type="text" order="ascending"/>
                <xsl:variable name="clipid" select="@id"/>
                <xsl:if test="not(contains($clipid,'_'))">
                    <li>
                        <xsl:call-template name="clip-icon">
                            <xsl:with-param name="clipid" select="$clipid"/>
                        </xsl:call-template>
                        <xsl:variable name="clipname">
                            <xsl:choose>
                                <xsl:when test="property[@name='kdenlive:clipname']">
                                    <xsl:value-of select="property[@name='kdenlive:clipname']"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="replace(property[@name='resource'],'.*/','')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <b><xsl:value-of select="$clipname"/></b>:

                        <xsl:if test="property[@name='kdenlive:folderid']">
                            <xsl:variable name="foldersuffix" select="concat('.',property[@name='kdenlive:folderid'])"/>
                            <xsl:variable name="folder" select="$folders[substring(@name,string-length(@name) - string-length($foldersuffix) + 1)=$foldersuffix]"/>
                            (<i>length:
                                <xsl:call-template name="show-timecode">
                                    <xsl:with-param name="frames" select="@out"/>
                                </xsl:call-template>,<xsl:text> </xsl:text>
                            from folder</i>: <b><xsl:value-of select="$folder/text()"/></b>)
                        </xsl:if>

                        producer id: <xsl:value-of select="@id"/>,

                        length: <xsl:call-template name="show-timecode"><xsl:with-param name="frames" select="@out"/></xsl:call-template>,<xsl:text> </xsl:text>
                    </li>
                </xsl:if>
            </xsl:for-each>
        </ul>
    </xsl:template>


    <xsl:include href="kpa-internal-video-compositing.xsl"/>
    <xsl:include href="kpa-internal-audio-mixing.xsl"/>

</xsl:stylesheet>
