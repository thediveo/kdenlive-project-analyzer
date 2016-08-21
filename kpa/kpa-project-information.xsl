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
                            <xsl:with-param name="description">Kdenlive project:</xsl:with-param>
                            <xsl:with-param name="text" select="$project-name"/>
                        </xsl:call-template>
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


</xsl:stylesheet>
