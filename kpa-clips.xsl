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


</xsl:stylesheet>
