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
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:regexp="http://exslt.org/regular-expressions"
                extension-element-prefixes="regexp">

    <!-- Produce HTML5 document on an XSLT processor which does not
         support disable-output-escaping in order to generate the
         HTML5 !DOCTYPE. HTML5 thus defines a legacy doctype.
      -->
    <xsl:output method="html"
                doctype-system="about:legacy-compat"
                encoding="utf-8"
                indent="yes"/>

    <xsl:variable name="version" select="'0.9.1'"/>


    <!-- We later need this key to group clips by their "name", where "name" is
         a slightly involved concept. A clip name is either its name as explicitly
         assigned by the user, or the filename+extension, but without its file path.
      -->
    <xsl:key name="clipkey" match="producer" use="substring(concat(regexp:replace(property[@name='resource'],'.*/','gi',''),property[@name='kdenlive:clipname']),1,1)"/>


    <!-- Generate the XHTML document head and body as we just start disecting
         the MLT XML document
      -->
    <xsl:template match="/">
        <html>
            <head>
                <title>Kdenlive Project Disection</title>

                <link rel="stylesheet" href="font-awesome/css/font-awesome.min.css"/>

                <style type="text/css"><![CDATA[
                    body {
                        font-family: Arial, sans-serif;
                    }

                    h2 {
                        margin-top: 2.5ex;
                        padding-bottom: 0.35ex;
                        border-bottom: solid #aaa 0.2ex;
                    }

                    h3 {
                        max-width: 15em;
                        margin-top: 3ex;
                        padding-bottom: 0.35ex;
                        border-bottom: solid #aaa 0.1ex;
                    }

                    ul.project-bin-contents,
                    ul.project-bin-contents ul,
                    ul.project-clips,
                    ul.tracks {
                        list-style: none;
                    }

                    ul.project-bin-contents,
                    ul.project-clips,
                    ul.tracks {
                        padding-left: 0.5em;
                    }

                    ul.project-bin-contents ul {
                        padding-left: 2em;
                    }

                    ul.tracks li {
                        border-top: 0.3ex dotted #aaa;
                        padding-top: .75ex;
                        padding-bottom: .75ex;
                        padding-left: 0.75em;
                        padding-right: 0.75em;
                    }

                    ul.tracks li:last-child {
                        border-bottom: 0.3ex dotted #aaa;
                    }

                    li {
                        padding-top: 0.6ex;
                    }

                    .warning {
                        font-weight: bolder !important;
                        color: #c80 !important;
                    }

                    .error {
                        font-weight: bolder !important;
                        color: #800 !important;
                    }

                    .anno-id, .anno {
                        color: #777;
                    }

                    .anno-unlocked,
                    .anno-opaque,
                    .anno-visible,
                    .anno-audible {
                        color: #777;
                    }

                    .anno-locked,
                    .anno-hidden,
                    .anno-muted {
                        color: #900;
                    }

                    .in-track {
                        font-size: 80%;
                        border-top: 0.3ex dotted;
                        border-bottom: 0.3ex dotted;
                        padding: 0.35ex 0.6em;
                        background-color: rgba(0,0,0,0.08);
                    }

                    table.borderless {
                        border-width: 0;
                    }

                    table.borderless td {
                        padding-left: 0.5em;
                        padding-right: 0.5em;
                        padding-top: 0.3ex;
                    }

                    .track-icon {
                        display: inline-block;
                        width: 2.7em;
                    }

                    .track-title {
                        display: inline-block;
                        text-overflow: ellipsis;
                        width: 15em;
                        white-space: nowrap;
                        overflow: hidden !important;
                        vertical-align: middle;
                    }

                    .track-states {
                        display: inline-block;
                        width: 11em;
                    }

                    .track-length {
                        display: inline-block;
                        width: 8em;
                    }

                    .fix-fa {
                        width: 1.7em;
                        float: left;
                    }

                ]]></style>
            </head>
            <body>
                <h1><img src="64-apps-kdenlive.png" style="vertical-align: text-bottom; height: 2ex;"/>&#8201;Kdenlive Project Analysis</h1>

                <p class="anno">Analysis script version: <xsl:value-of select="$version"/> / (c) 2016 Harald Albrecht / <a href="https://thediveo.github.io/kdenlive-project-analyzer/kdenlive-project-analyzer.html">Online</a> / <a href="https://thediveo.github.io/kdenlive-project-analyzer/">Project on GitHub</a></p>

                <!-- Sanity checks -->
                <!-- Not even remotely a Kdenlive project... -->
                <xsl:choose>
                    <xsl:when test="count(/mlt)!=1">
                        <p><b class="error">Error:</b> this is not a valid Kdenlive/MLT project; <xsl:value-of select="count(/mlt)"/> &lt;mlt&gt; element(s) found.</p>
                    </xsl:when>
                    <xsl:when test="/mlt/@producer!='main bin'">
                        <p><b class="error">Error:</b> this is not a valid Kdenlive project (MLT producer missing/invalid).</p>
                    </xsl:when>
                    <xsl:when test="number(/mlt/playlist[@id='main bin']/property[@name='kdenlive:docproperties.version'])&lt;0.91">
                        <p><b class="error">Error:</b> unsupported old Kdenlive project document version "<xsl:value-of select="/mlt/playlist[@id='main bin']/property[@name='kdenlive:docproperties.version']"/>"; can only analyze document from version 0.91 on and later.</p>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="analyze-kdenlive-project"/>
                    </xsl:otherwise>
                </xsl:choose>
            </body>
        </html>
    </xsl:template>


    <!-- This analyzes a complete Kdenlive document by wiring up the individual
         analysis sections and throws in some explanatory texts that should help
         newcomers to better understand and interpret the analysis results.
      -->
    <xsl:template name="analyze-kdenlive-project">
        <h2><i class="fa fa-info-circle" aria-hidden="true"/> General Project Information</h2>

        <p>Information that is stored inside this Kdenlive project.</p>
        <xsl:call-template name="show-kdenlive-project-info"/>


        <h2><i class="fa fa-pie-chart" aria-hidden="true"/> Project Statistics</h2>

        <p>The following project statistics are not stored directly inside Kdenlive project, but instead are derived from various other information elements inside this Kdenlive project.</p>
        <xsl:call-template name="show-kdenlive-project-statistics"/>


        <h2><i class="fa fa-sitemap" aria-hidden="true"/> Project Bin Contents</h2>

        <p>All project bin clips, as organized into <xsl:value-of select="$bin-num-folders"/> bin folders. These bin folders are purely a Kdenlive construct, whereas MLT doesn't know about and also doesn't need folders.</p>
        <xsl:call-template name="list-folders-of-folder">
            <xsl:with-param name="parentfolderid" select="-1"/>
        </xsl:call-template>


        <h2><i class="fa fa-bars" aria-hidden="true"/> Tracks Configuration</h2>

        <p>All the configured timeline tracks, from the topmost track down to the bottommost track in the timeline. Please note that MLT has a different understanding of topmost and bottommost: exactly the opposite of what we see in Kdenlive's timeline.</p>
        <xsl:call-template name="list-all-tracks"/>


        <h2><i class="fa fa-eye-slash" aria-hidden="true"/> Internally Added Track Transitions</h2>

        <p>Behind the scenes, Kdenlive does some MLT magic in order to achieve both sound mixing and video layer compositing across tracks. Thus, Kdenlive effectively hides some slightly nasty MLT peculiarities: for instance, unless explicitly told so, MLT won't ever mix audio from multiple (audio) tracks. This section may help in diagnosing slightly errartic Kdenlive projects with either odd audio mixing or odd video compositing.</p>
        <xsl:call-template name="show-timeline-video-compositing"/>
        <xsl:call-template name="show-timeline-audio-mixing"/>


        <h2><i class="fa fa-th" aria-hidden="true"/> Master Clip List</h2>

        <p>All master clips from Kdenlive's project bin, flat, sorted by their names. In addition, derived producers are shown were created in the project.</p>
        <xsl:call-template name="list-all-clips"/>
    </xsl:template>


    <!-- Display general information about this Kdenlive project.
      -->
    <xsl:template name="show-kdenlive-project-info">
        <xsl:variable name="project" select="/mlt/playlist[@id='main bin']"/>
        <xsl:variable name="docversion" select="$project/property[@name='kdenlive:docproperties.version']"/>
        <xsl:choose>
            <xsl:when test="$docversion">
                <table class="borderless">
                    <tbody>
                        <xsl:call-template name="show-description-with-value">
                            <xsl:with-param name="description">Kdenlive project ID:</xsl:with-param>
                            <xsl:with-param name="text" select="$project/property[@name='kdenlive:docproperties.documentid']"/>
                        </xsl:call-template>
                        <xsl:call-template name="show-description-with-value">
                            <xsl:with-param name="description">Kdenlive project document version:</xsl:with-param>
                            <xsl:with-param name="text" select="$docversion"/>
                        </xsl:call-template>
                        <xsl:call-template name="show-description-with-value">
                            <xsl:with-param name="description">Created by Kdenlive version:</xsl:with-param>
                            <xsl:with-param name="text" select="$project/property[@name='kdenlive:docproperties.kdenliveversion']"/>
                        </xsl:call-template>
                        <xsl:call-template name="show-description-with-value">
                            <xsl:with-param name="description">Serialized by MLT version:</xsl:with-param>
                            <xsl:with-param name="text" select="/mlt/@version"/>
                        </xsl:call-template>
                        <xsl:call-template name="show-description-with-value">
                            <xsl:with-param name="description">Project folder:</xsl:with-param>
                            <xsl:with-param name="copy">
                                <xsl:choose>
                                    <xsl:when test="starts-with($project/property[@name='kdenlive:docproperties.projectfolder']/text(), '/')">
                                        <xsl:call-template name="error-icon"/>&#160;Absolute project folder path:
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <span class="anno"><xsl:value-of select="/mlt/@root"/>/</span>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:value-of select="$project/property[@name='kdenlive:docproperties.projectfolder']"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="show-description-with-value">
                            <xsl:with-param name="description">Root folder:</xsl:with-param>
                            <xsl:with-param name="text" select="/mlt/@root"/>
                        </xsl:call-template>
                        <xsl:call-template name="show-description-with-value">
                            <xsl:with-param name="description">Locale to be used:</xsl:with-param>
                            <xsl:with-param name="text" select="/mlt/@LC_NUMERIC"/>
                        </xsl:call-template>
                        <xsl:if test="/mlt/profile/@description">
                            <xsl:call-template name="show-description-with-value">
                                <xsl:with-param name="description">Profile description:</xsl:with-param>
                                <xsl:with-param name="text" select="/mlt/profile/@description"/>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:call-template name="show-description-with-value">
                            <xsl:with-param name="description">Profile:</xsl:with-param>
                            <xsl:with-param name="text">
                                <xsl:value-of select="/mlt/profile/@width"/>&#215;<xsl:value-of select="/mlt/profile/@height"/>,

                                <xsl:value-of select="/mlt/profile/@display_aspect_num"/>:<xsl:value-of select="/mlt/profile/@display_aspect_den"/>,

                                <xsl:value-of select="/mlt/profile/@frame_rate_num"/>/<xsl:value-of select="/mlt/profile/@frame_rate_den"/> frames/s,

                                <xsl:value-of select="/mlt/profile/@sample_aspect_num"/>:<xsl:value-of select="/mlt/profile/@sample_aspect_den"/> pixel aspect ratio
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="show-description-with-value">
                            <xsl:with-param name="description">Color space:</xsl:with-param>
                            <xsl:with-param name="text" select="/mlt/profile/@colorspace"/>
                        </xsl:call-template>
                    </tbody>
                </table>
            </xsl:when>
            <xsl:otherwise>
                <b>This does not seem to be a Kdenlive project document!</b>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- Display statistics about this Kdenlive project.
      -->
    <xsl:template name="show-kdenlive-project-statistics">
        <table class="borderless">
            <tbody>
                <xsl:call-template name="show-description-with-value">
                    <xsl:with-param name="description">Timeline total length:</xsl:with-param>
                    <xsl:with-param name="copy"><xsl:call-template name="show-timeline-length"/></xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="show-description-with-value">
                    <xsl:with-param name="description">Number of timeline tracks:</xsl:with-param>
                    <xsl:with-param name="copy"><xsl:value-of select="$num-timeline-tracks - 1"/> <span class="anno"> (<i>+1 hidden built-in "Black" track</i>)</span></xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="show-description-with-value">
                    <xsl:with-param name="description">&#8230; audio/video tracks:</xsl:with-param>
                    <xsl:with-param name="copy">&#8230; <xsl:value-of select="$num-timeline-av-tracks"/> &#215; <xsl:call-template name="video-track-icon"/></xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="show-description-with-value">
                    <xsl:with-param name="description">&#8230; audio tracks:</xsl:with-param>
                    <xsl:with-param name="copy">&#8230; <xsl:value-of select="$num-timeline-audio-tracks"/> &#215; <xsl:call-template name="audio-track-icon"/></xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="show-description-with-value">
                    <xsl:with-param name="description">Number of bin clips:</xsl:with-param>
                    <xsl:with-param name="copy"><xsl:value-of select="$bin-num-master-clips"/> &#215; <i class="fa fa-files-o" title="bin clip"/></xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="show-description-with-value">
                    <xsl:with-param name="description">&#8230; audio-only clips:</xsl:with-param>
                    <xsl:with-param name="copy">&#8230; <xsl:value-of select="$num-bin-master-audio-clips"/> &#215; <xsl:call-template name="audio-clip-icon"/></xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="show-description-with-value">
                    <xsl:with-param name="description">&#8230; (audio+) video clips:</xsl:with-param>
                    <xsl:with-param name="copy">&#8230; <xsl:value-of select="$num-bin-master-audiovideo-clips"/> &#215; <xsl:call-template name="av-clip-icon"/></xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="show-description-with-value">
                    <xsl:with-param name="description">&#8230; image clips:</xsl:with-param>
                    <xsl:with-param name="copy">&#8230; <xsl:value-of select="$num-bin-master-image-clips"/> &#215; <xsl:call-template name="image-clip-icon"/></xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="show-description-with-value">
                    <xsl:with-param name="description">&#8230; image squence clips:</xsl:with-param>
                    <xsl:with-param name="copy">&#8230; <xsl:value-of select="$num-bin-master-imageseq-clips"/> &#215; <xsl:call-template name="image-sequence-clip-icon"/></xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="show-description-with-value">
                    <xsl:with-param name="description">&#8230; title clips:</xsl:with-param>
                    <xsl:with-param name="copy">&#8230; <xsl:value-of select="$num-bin-master-title-clips"/> &#215; <xsl:call-template name="title-clip-icon"/></xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="show-description-with-value">
                    <xsl:with-param name="description-copy">&#8230; colo<span style="opacity: 0.5;">u</span>r clips:</xsl:with-param>
                    <xsl:with-param name="copy">&#8230; <xsl:value-of select="$num-bin-master-color-clips - 1"/> &#215; <xsl:call-template name="color-clip-icon"/> <span class="anno"> (<i>+1 hidden built-in "Black" color clip</i>)</span></xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="show-description-with-value">
                    <xsl:with-param name="description">Number of bin folders:</xsl:with-param>
                    <xsl:with-param name="copy"><xsl:value-of select="$bin-num-folders"/> &#215; <i class="fa fa-folder-o"/></xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="show-description-with-value">
                    <xsl:with-param name="description">Number of timeline transitions:</xsl:with-param>
                    <xsl:with-param name="copy"><xsl:value-of select="$num-user-transitions"/> &#215; <xsl:call-template name="transition-icon"/></xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="show-description-with-value">
                    <xsl:with-param name="description">Number of internally added transitions:</xsl:with-param>
                    <xsl:with-param name="copy"><xsl:value-of select="$num-internally-added-transitions"/> &#215; <xsl:call-template name="transition-icon"/></xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="show-description-with-value">
                    <xsl:with-param name="description">&#8230; audio mixers:</xsl:with-param>
                    <xsl:with-param name="copy">&#8230; <xsl:value-of select="$num-internally-added-mix-transitions"/> &#215; <xsl:call-template name="audio-track-icon"/></xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="show-description-with-value">
                    <xsl:with-param name="description">&#8230; video compositors:</xsl:with-param>
                    <xsl:with-param name="copy">&#8230; <xsl:value-of select="$num-internally-added-compositing-transitions"/> &#215; <xsl:call-template name="video-track-icon"/></xsl:with-param>
                </xsl:call-template>
           </tbody>
        </table>
    </xsl:template>


    <!-- Render a description with a value/selector in form of a table row
         consisting of exactly two columns: left col for description, right
         col for value.

         Parameters:
         * description: text to output in left cell.
         * text: optional/preferred, the value to output in right cell.
         * copy: optional, the node set to copy into the right cell.
      -->
    <xsl:template name="show-description-with-value">
        <xsl:param name="description"/>
        <xsl:param name="description-copy"/>
        <xsl:param name="text"/>
        <xsl:param name="copy"/>
        <tr>
            <td>
                <xsl:choose>
                    <xsl:when test="$description"><xsl:value-of select="$description"/></xsl:when>
                    <xsl:otherwise><xsl:copy-of select="$description-copy"/></xsl:otherwise>
                </xsl:choose>
                </td>
            <td>
                <xsl:choose>
                    <xsl:when test="$text"><xsl:value-of select="$text"/></xsl:when>
                    <xsl:otherwise><xsl:copy-of select="$copy"/></xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>


    <!-- Gather all timeline tracks, and some associated information. This
         later helps us avoiding using the same XPath code over and over
         again, with some subtle bugs between different instances...
      -->
    <xsl:variable name="timeline-tracks" select="/mlt/tractor[@id='maintractor']/track"/>
    <xsl:variable name="num-timeline-tracks" select="count($timeline-tracks)"/>
    <xsl:variable name="num-timeline-user-tracks" select="$num-timeline-tracks -1"/>

    <!-- Type-specific timeline tracks -->
    <xsl:variable name="timeline-av-tracks" select="/mlt/playlist[boolean(property[@name='kdenlive:track_name']) and not(property[@name='kdenlive:audio_track'] = '1')]"/>
    <xsl:variable name="num-timeline-av-tracks" select="count($timeline-av-tracks)"/>

    <xsl:variable name="timeline-audio-tracks" select="/mlt/playlist[boolean(property[@name='kdenlive:track_name']) and (property[@name='kdenlive:audio_track'] = '1')]"/>
    <xsl:variable name="num-timeline-audio-tracks" select="count($timeline-audio-tracks)"/>


    <!-- Gather all project bin folders -->
    <xsl:variable name="bin-folders" select="/mlt/playlist[@id='main bin']/property[starts-with(@name,'kdenlive:folder.')]"/>
    <xsl:variable name="bin-num-folders" select="count($bin-folders)"/>


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


    <!-- Gather all user-created transitions -->
    <xsl:variable name="user-transitions" select="/mlt/tractor[@id='maintractor']/transition[not(property[@name='internal_added']/text()='237')]"/>
    <xsl:variable name="num-user-transitions" select="count($user-transitions)"/>


    <!-- Gather all internally added transitions -->
    <xsl:variable name="internally-added-transitions" select="/mlt/tractor[@id='maintractor']/transition[property[@name='internal_added']/text()='237']"/>
    <xsl:variable name="num-internally-added-transitions" select="count($internally-added-transitions)"/>


    <!-- Gather all internally added audio mix transitions -->
    <xsl:variable name="internally-added-mix-transitions" select="/mlt/tractor[@id='maintractor']/transition[property[@name='internal_added']/text()='237'][property[@name='mlt_service']/text()='mix']"/>
    <xsl:variable name="num-internally-added-mix-transitions" select="count($internally-added-mix-transitions)"/>


    <!-- Gather all internally added video compositing transitions -->
    <xsl:variable name="internally-added-compositing-transitions" select="/mlt/tractor[@id='maintractor']/transition[property[@name='internal_added']/text()='237'][not(property[@name='mlt_service']/text()='mix')]"/>
    <xsl:variable name="num-internally-added-compositing-transitions" select="count($internally-added-compositing-transitions)"/>


    <!-- Clip-type specific icons -->
    <!-- generic or A/V clip icon -->
    <xsl:template name="av-clip-icon">
        <i class="fa fa-file-video-o" title="A/V clip"/>
    </xsl:template>


    <!-- audio clip icon -->
    <xsl:template name="audio-clip-icon">
        <i class="fa fa-file-audio-o" title="audio clip"/>
    </xsl:template>


    <!-- image clip icon -->
    <xsl:template name="image-clip-icon">
        <i class="fa fa-picture-o" title="image clip"/>
    </xsl:template>


    <!-- image sequence clip icon -->
    <xsl:template name="image-sequence-clip-icon">
        <span title="image sequence clip">
            <i class="fa fa-picture-o" title="image sequence clip"/>&#8201;<i class="fa fa-picture-o"/>&#8201;&#8226;&#8226;&#8226;
        </span>
    </xsl:template>


    <!-- title clip icon -->
    <xsl:template name="title-clip-icon">
        <i class="fa fa-font" title="audio clip"/>
    </xsl:template>


    <!-- color clip icon -->
    <xsl:template name="color-clip-icon">
        <span style="font-size:50%; letter-spacing: -0.3em;" aria-hidden="true" title="color clip">
            <i class="fa fa-circle" style="color: #c00;"/>
            <i class="fa fa-circle" style="color: #0c0;"/>
            <i class="fa fa-circle" style="color: #00c;"/>
        </span>
    </xsl:template>


    <!-- More icon definitions -->
    <!-- generic transition icon -->
    <xsl:template name="transition-icon">
        <i class="fa fa-clone in-track"/>
    </xsl:template>


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


    <!-- Show an error icon -->
    <xsl:template name="error-icon">
        <i class="fa fa-exclamation-triangle error"/>
    </xsl:template>


    <!-- Show a warning icon -->
    <xsl:template name="warning-icon">
        <i class="fa fa-exclamation-circle warning"/>&#160;
    </xsl:template>


    <!-- Heuristics for finding out flavor of transparent tracks are used in
         a Kdenlive project.

         Please note that for old track-wise projects the compositing transitions
         are only present for the tracks for which automatic compositing is enabled,
         that is, only for "transparent tracks".

         These heuristics may totally mess up when the internally added
         transitions are totally messed up. No wonder.

         Possible values are:
         * none: no suitable information about compositing found
         * track: old track-wise controllable compositing
         * preview: new timeline-wise preview-quality compositing
         * hq: new timeline-wise high-quality compositing
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


    <!-- Show a short notice about the (assumed) timeline compositing mode.
      -->
    <xsl:template name="timeline-compositing-info">
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


    <!-- Show transparent track state icon -->
    <xsl:template name="transparent-track-icon">
        <i class="fa fa-delicious anno-composite" aria-hidden="true" title="transparent track"/>&#160;
    </xsl:template>


    <!-- Show opaque track state icon -->
    <xsl:template name="opaque-track-icon">
        <i class="fa fa-square-o anno-opaque" aria-hidden="true" title="opaque track"/>&#160;
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

        <xsl:call-template name="timeline-compositing-info"/>

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

        <p>
            The total timeline length is <xsl:call-template name="show-timeline-length"/>.
        </p>

        <p>
            The bottommost <i>video</i> track is track
            "<xsl:call-template name="show-track-title">
                <xsl:with-param name="mlt-track-idx" select="$timeline-lowest-video-track"/>
                <xsl:with-param name="class" select="''"/>
            </xsl:call-template>"
            <span class="anno">(<i>MLT track index: <xsl:value-of select="$timeline-lowest-video-track"/></i>)</span>
        </p>
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


    <!-- Calculate total length of a track in frames -->
    <xsl:template name="calc-track-length">
        <xsl:param name="mlt-track-idx"/>

        <xsl:variable name="track-ref" select="$timeline-tracks[$mlt-track-idx+1]/@producer"/>
        <xsl:variable name="track-playlist" select="/mlt/playlist[@id=$track-ref]"/>

        <xsl:variable name="s" select="sum($track-playlist/blank/@length)"/>
        <xsl:variable name="i" select="sum($track-playlist/entry/@in)"/>
        <xsl:variable name="o" select="sum($track-playlist/entry/@out)"/>
        <xsl:value-of select="$o - $i + $s"/>
    </xsl:template>


    <xsl:template name="max-timeline-length">
        <xsl:param name="mlt-track-idx" select="1"/>

        <xsl:variable name="len">
            <xsl:call-template name="calc-track-length">
                <xsl:with-param name="mlt-track-idx" select="$mlt-track-idx"/>
            </xsl:call-template>
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

        <!-- calculate total track length -->
        <span class="track-length">
            <xsl:call-template name="show-timecode">
                <xsl:with-param name="frames">
                    <xsl:call-template name="calc-track-length">
                        <xsl:with-param name="mlt-track-idx" select="$mlt-track-idx"/>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:call-template>
        </span>

        <!-- internal information -->
        <span class="anno-id"> (<i>track id: "<xsl:value-of select="$track-ref"/>", MLT track index: <xsl:value-of select="$mlt-track-idx"/></i>)</span>
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


    <!-- One out of several purposes of the "main bin" playlist is to
         describe Kdenlive's bin folder structure of this project. The
         folders are <property> elements, with names starting with
         "kdenlive:folder." followed by "p.f" where:
         * f is the folder id (simple an int number) of this particular
           bin folder.
         * p is the parent folder id, or "-1" in case it's a top-level
           folder.
         Finally, the folder name is stored as the text content of the
         <propert> element.
      -->
    <!-- Generates a (recursive) list of project bin folder for a
         specific parent folder id (where id "-1" lists all bin folders
         at top level). This list of bin folders is sorted alphabetically,
         in the same way Kdenlive's project bin pane sorts its elements.
         * param parentfolderid: the folder id of the parent folder,
             or -1 if listing the top level folders.
      -->
    <xsl:template name="list-folders-of-folder">
        <xsl:param name="parentfolderid"/>
        <xsl:variable name="prefix" select="concat('kdenlive:folder.',$parentfolderid,'.')"/>
        <xsl:variable name="folders" select="/mlt/playlist[@id='main bin']/property[starts-with(@name,$prefix)]"/>
        <ul class="project-bin-contents">
            <xsl:if test="count($folders)">
                <xsl:for-each select="$folders">
                    <!-- Emulate more/less how Kdenlive sorts its project bin folders:
                         alphabetically... -->
                    <xsl:sort select="text()" data-type="text" order="ascending"/>
                    <xsl:variable name="folderid" select="substring-after(@name,$prefix)"/>
                    <li>
                        <i class="fa fa-folder-o" aria-hidden="true" title="bin folder"/>&#160;<b><xsl:value-of select="text()"/></b>
                        <span class="anno-id"> (<i>folder id: <xsl:value-of select="$folderid"/></i>)</span>

                        <!-- List all folders inside this folder, recursing down into
                             subfolders. -->
                        <xsl:call-template name="list-folders-of-folder">
                            <xsl:with-param name="parentfolderid" select="substring-after(@name,$prefix)"/>
                        </xsl:call-template>

                        <!-- List all clips in this folder. -->
                        <ul>
                            <xsl:call-template name="list-clips-in-folder">
                                <xsl:with-param name="folderid" select="$folderid"/>
                            </xsl:call-template>
                        </ul>
                    </li>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="$parentfolderid=-1">
                <xsl:call-template name="list-clips-in-folder">
                    <xsl:with-param name="folderid" select="-1"/>
                </xsl:call-template>
            </xsl:if>
        </ul>
    </xsl:template>

    <!-- Generates a list of clips inside a particular project bin folder.
         If a clip has its clipname set, then this is listed. If no clipname
         has been set, then we list the basename+extension of the clip
         resource setting.

         Important: enclose the template call with either <ul> or <ol>, as
         the template only generates <li> list items - but not the list itself.

         * param folderid: the folder id of the folder containing the clips
             to be listed. If -1, then all clips not organized into one of
             the folders are listed instead.
      -->
    <xsl:template name="list-clips-in-folder">
        <xsl:param name="folderid"/>
        <!-- Selecting is rather tricky because we need to differentiate:
             * folderid=-1 means that we need to select <producer>s without any
               <property name="kdenlive:folderid"/> children.
             * folderid>0 means that we need to select only those <producers> which
               have a <property name="kdenlive:folderid"> where the value matches
               the folderid specified. And all this in the restricted expressiveness
               that XSLT 1.0 gives us (not).
          -->
        <!-- Note that clips is a set of <producer>s -->
        <xsl:variable name="clips" select="/mlt/producer/property[$folderid>-1 and @name='kdenlive:folderid' and text()=$folderid]/.. | /mlt/producer[$folderid=-1 and not(property[@name='kdenlive:folderid'])]"/>
        <xsl:for-each select="$clips">
            <!-- Emulate to some extent how Kdenlive sorts its project bin elements,
                 especially clips; the name for which to sort is the clip name, if
                 explicitly set. If unset, then the clips basename+ext is used for
                 sorting. -->
            <xsl:sort select="concat(regexp:replace(property[@name='resource'],'.*/','gi',''),property[@name='kdenlive:clipname'])" order="ascending"/>
            <xsl:variable name="clipid" select="@id"/>
            <xsl:if test="not(contains($clipid,'_'))">
                <li>
                    <xsl:choose>
                        <!-- special case: built-in "black" clip -->
                        <xsl:when test="$clipid='black'">
                            <span class="anno"><i class="fa fa-eye-slash"/>&#160;<i>hidden built-in</i>&#160;<b>black</b> clip</span>
                        </xsl:when>
                        <!-- all other non built-in clips -->
                        <xsl:otherwise>
                            <xsl:call-template name="clip-icon">
                                <xsl:with-param name="clipid" select="$clipid"/>
                            </xsl:call-template>
                            <xsl:choose>
                                <xsl:when test="property[@name='kdenlive:clipname']">
                                    <xsl:value-of select="property[@name='kdenlive:clipname']"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="regexp:replace(property[@name='resource'],'.*/','gi','')"/>
                                </xsl:otherwise>
                            </xsl:choose>

                            <xsl:if test="property[@name='mlt_service']/text()='color'">
                                <xsl:variable name="rgb" select="substring(property[@name='resource']/text(),3,6)"/>
                                <xsl:text> </xsl:text><i class="fa fa-square" style="color: #{$rgb};"/>
                                (RGB/A: <xsl:value-of select="$rgb"/>/<xsl:value-of select="substring(property[@name='resource']/text(),9,2)"/>)
                            </xsl:if>

                            <span class="anno-id"> (<i>length:
                                <xsl:call-template name="show-timecode">
                                    <xsl:with-param name="frames" select="@out"/>
                                </xsl:call-template>,<xsl:text> </xsl:text>
                                clip id: <xsl:value-of select="$clipid"/>
                                </i>)</span>
                        </xsl:otherwise>
                    </xsl:choose>
                </li>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>


    <!-- -->
    <xsl:template name="show-timecode">
        <xsl:param name="frames"/>

        <xsl:variable name="fps" select="round(/mlt/profile/@frame_rate_num div /mlt/profile/@frame_rate_den)"/>

        <xsl:variable name="ff" select="format-number($frames mod $fps, '00')"/>
        <xsl:variable name="ss" select="format-number(floor($frames div $fps) mod 60, '00')"/>
        <xsl:variable name="mm" select="format-number(floor(($frames div $fps) div 60) mod 60, '00')"/>
        <xsl:variable name="hh" select="format-number(floor(($frames div $fps) div 3600), '00')"/>

        <tt><xsl:value-of select="$hh"/>:<xsl:value-of select="$mm"/>:<xsl:value-of select="$ss"/>.<xsl:value-of select="$ff"/></tt>
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
                            <xsl:when test="starts-with(regexp:replace(property[@name='resource'],'.*/','gi',''),'.all.')">
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
                <xsl:sort select="concat(property[@name='kdenlive:clipname'],regexp:replace(property[@name='resource'],'.*/','gi',''),property[@name='resource'])" data-type="text" order="ascending"/>
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
                                    <xsl:value-of select="regexp:replace(property[@name='resource'],'.*/','gi','')"/>
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


    <!-- Matches all internally added transitions according to their a_track
         parameter. This key surely wins us the price for overly descriptive
         naming.
      -->
    <xsl:key name="internal-composite-transition-by-a-track" match="transition[(property[@name='internal_added']/text()='237') and (not(property[@name='mlt_service']/text()='mix'))]" use="property[@name='a_track']"/>

    <!-- -->
    <xsl:template name="show-timeline-video-compositing">
        <h3><span class="in-track"><i class="fa fa-clone" aria-hidden="true"/>&#8201;<i class="fa fa-film" aria-hidden="true"/></span> Video Compositing</h3>

        <p>For automatic video track compositing, Kdenlives creates the following compositing transitions automatically behind the scenes.</p>

        <xsl:call-template name="timeline-compositing-info"/>


        <!-- Sanity check to quickly identify slightly insane Kdenlive projects -->
        <xsl:if test="$num-timeline-av-tracks &lt; $num-internally-added-compositing-transitions">
            <p><xsl:call-template name="warning-icon"/><span class="warning">Warning: </span>found <i>more</i> internally added video compositing transitions (<xsl:value-of select="$num-internally-added-compsiting-transitions"/>) than actual video tracks (<xsl:value-of select="$num-timeline-av-tracks"/>) in project &#8211; this project may need some
                <xsl:if test="($num-internally-added-mix-transitions - $num-timeline-av-tracks) &gt; 1">
                    <xsl:text> </xsl:text><b>serious</b>
                </xsl:if>
                <xsl:text> </xsl:text>XML cleanup.</p>
        </xsl:if>

        <xsl:if test="$num-timeline-av-tracks - 1 &gt; $num-internally-added-compositing-transitions">
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
                        <xsl:if test="$mlt-track-idx &gt; $timeline-lowest-video-track">
                             <i class="fa fa-film" aria-hidden="true" title="internally added compositing transition"/>
                        </xsl:if>
                        <xsl:if test="(count($track-comp-transitions) = 0) and ($mlt-track-idx &gt; $timeline-lowest-video-track)">
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
