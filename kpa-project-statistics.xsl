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


    <!-- Lies, damned lies, and statistcis: display some nice statistics
         about this Kdenlive project. Don't know whether this actually makes
         sense, but it surely may give you a warm feeling when you can
         brag about your timeline having more clips and transitions as mine... ;)
      -->
    <xsl:template name="show-kdenlive-project-statistics">
        <table class="borderless">
            <tbody>
                <xsl:call-template name="show-description-with-value">
                    <xsl:with-param name="description">Overall timeline length:</xsl:with-param>
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
                    <xsl:with-param name="description">&#8230; timeline clips:</xsl:with-param>
                    <xsl:with-param name="copy">&#8230; <xsl:value-of select="$num-timeline-clips"/> &#215; <i class="fa fa-files-o" title="timeline clips"/></xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="show-description-with-value">
                    <xsl:with-param name="description">Number of bin clips:</xsl:with-param>
                    <xsl:with-param name="copy"><xsl:value-of select="$bin-num-master-clips"/> &#215; <i class="fa fa-files-o" title="bin clips"/></xsl:with-param>
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
                    <xsl:with-param name="description">&#8230; video compositors:</xsl:with-param>
                    <xsl:with-param name="copy">&#8230; <xsl:value-of select="$num-internally-added-compositing-transitions"/> &#215; <xsl:call-template name="video-track-icon"/></xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="show-description-with-value">
                    <xsl:with-param name="description">&#8230; audio mixers:</xsl:with-param>
                    <xsl:with-param name="copy">&#8230; <xsl:value-of select="$num-internally-added-mix-transitions"/> &#215; <xsl:call-template name="audio-track-icon"/></xsl:with-param>
                </xsl:call-template>
           </tbody>
        </table>
    </xsl:template>


</xsl:stylesheet>
