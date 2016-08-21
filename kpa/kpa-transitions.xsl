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


<!-- Useful variables related to transitions -->

    <!-- All user-created transitions, regardless of track. This node set
         excludes the so-called internally-added transition that Kdenlive
         sets up for automatic audio mixing and track compositing.
      -->
    <xsl:variable name="user-transitions" select="$main-tractor/transition[not(property[@name='internal_added'] = '237')]"/>
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


    <!-- Calculate the latest out point of the latest transition for
         a given timeline track. For this, we assume the Kdenlive model
         for transitions, where a transitions "belongs" to the B track
         referenced by a given transition.

         This template can be used to calculate the overall length of
         a particular track, or even the overall timeline length.

         Parameters:
         * mlt-track-idx: the (MLT) track index of the track for which
             to calculate the latest transition out point.
      -->
    <xsl:template name="calc-track-transitions-end">
        <xsl:param name="mlt-track-idx"/>

        <xsl:variable name="user-transitions" select="/mlt/tractor[@id='maintractor']/transition[not(property[@name='internal_added']) and property[@name='b_track'] = $mlt-track-idx]"/>

        <xsl:choose>
            <xsl:when test="count($user-transitions) = 0">
                0
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="max($user-transitions/@out)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


</xsl:stylesheet>
