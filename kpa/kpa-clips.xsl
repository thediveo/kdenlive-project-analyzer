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


    <!-- Gather all project bin *master* clips, and some statistics. Master clips
         are those producers with an id that doesn't contain "_" or ":".
      -->
    <xsl:variable name="bin-master-clips"
                  select="/mlt/producer[not(contains(@id, '_')) and not(contains(@id, ':'))]"/>
    <xsl:variable name="bin-num-master-clips" select="count($bin-master-clips)"/>


    <!-- All master audio-only clips: these can be detected as they don't have
         a video stream, thus the video stream index is -1.
      -->
    <xsl:variable name="bin-master-audio-clips"
                  select="/mlt/producer[not(contains(@id, '_')) and not(contains(@id, ':'))][property[@name='video_index']/text()='-1']"/>
    <xsl:variable name="num-bin-master-audio-clips" select="count($bin-master-audio-clips)"/>


    <!-- All master (audio+) video clips -->
    <xsl:variable name="bin-master-audiovideo-clips"
                  select="/mlt/producer[not(contains(@id, '_')) and not(contains(@id, ':'))][property[@name='video_index']/text()!='-1']"/>
    <xsl:variable name="num-bin-master-audiovideo-clips" select="count($bin-master-audiovideo-clips)"/>


    <!-- All master image clips: this gets complex, as we both have 'pixbuf' and
         'qimage' as image-producing services. In addition, we don't want to count
         here any image sequences, so we filter out any special wild-card resource
         names containing '.all.'.
      -->
    <xsl:variable name="bin-master-image-clips"
                  select="/mlt/producer[not(contains(@id, '_')) and not(contains(@id, ':'))][(property[@name='mlt_service']/text()='pixbuf' or property[@name='mlt_service']/text()='qimage') and not(contains(property[@name='resource']/text(), '.all.'))]"/>
    <xsl:variable name="num-bin-master-image-clips" select="count($bin-master-image-clips)"/>


    <!-- All master image sequence(!) clips -->
    <xsl:variable name="bin-master-imageseq-clips"
                  select="/mlt/producer[not(contains(@id, '_')) and not(contains(@id, ':'))][(property[@name='mlt_service']/text()='pixbuf') and contains(property[@name='resource']/text(), '.all.')]"/>
    <xsl:variable name="num-bin-master-imageseq-clips" select="count($bin-master-imageseq-clips)"/>


    <!-- All master color clips -->
    <xsl:variable name="bin-master-color-clips"
                  select="/mlt/producer[not(contains(@id, '_')) and not(contains(@id, ':'))][(property[@name='mlt_service']/text()='color') or (property[@name='mlt_service']/text()='colour')]"/>
    <xsl:variable name="num-bin-master-color-clips" select="count($bin-master-color-clips)"/>


    <!-- All master title clips -->
    <xsl:variable name="bin-master-title-clips"
                  select="/mlt/producer[not(contains(@id, '_')) and not(contains(@id, ':'))][property[@name='mlt_service']/text()='kdenlivetitle']"/>
    <xsl:variable name="num-bin-master-title-clips" select="count($bin-master-title-clips)"/>


    <!-- Renders a clip icon depending on the clip's type. The following clip icons are
         differentiated:
         * video clip (this is also the fallback in case we don't find a more specific icon)
         * audio-only clip
         * title clip
         * image clip
         * color clip
         * internal/hidden/built-in clip - such as the "black" clip in particular.

         Parameters:
         * clipid: the clip id of the <producer> representing the clip. This producer
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


</xsl:stylesheet>
