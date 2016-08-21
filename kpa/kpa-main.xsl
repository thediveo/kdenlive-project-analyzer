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


    <!-- Generate the XHTML document head and body as we just start disecting
         the MLT XML document
      -->
    <xsl:template match="/">
        <xsl:message>KPA: Analysis starts...</xsl:message>
        <html>
            <head>
                <title>Kdenlive Project Disection</title>

                <link rel="stylesheet" href="font-awesome/css/font-awesome.min.css"/>
                <link rel="stylesheet" href="style/kdenlive-project-analyzer.css"/>
            </head>
            <body>
                <div id="report">
                    <h1><img src="images/64-apps-kdenlive.png" style="vertical-align: text-bottom; height: 2ex;"/>&#8201;Kdenlive Project Analysis</h1>

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
                </div>
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


</xsl:stylesheet>
