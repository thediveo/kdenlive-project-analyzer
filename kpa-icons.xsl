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


    <!-- generic transition icon -->
    <xsl:template name="transition-icon">
        <i class="fa fa-clone in-track"/>
    </xsl:template>


    <!-- Show an error icon -->
    <xsl:template name="error-icon">
        <i class="fa fa-exclamation-triangle error"/>
    </xsl:template>


    <!-- Show a warning icon -->
    <xsl:template name="warning-icon">
        <i class="fa fa-exclamation-circle warning"/>&#160;
    </xsl:template>


</xsl:stylesheet>
