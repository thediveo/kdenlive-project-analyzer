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


    <!-- Gather all project bin folders -->
    <xsl:variable name="bin-folders" select="/mlt/playlist[@id='main bin']/property[starts-with(@name,'kdenlive:folder.')]"/>
    <xsl:variable name="bin-num-folders" select="count($bin-folders)"/>


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
            <xsl:if test="number($parentfolderid) = -1">
                <xsl:call-template name="list-clips-in-folder">
                    <xsl:with-param name="folderid" select="'-1'"/>
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
        <xsl:variable name="clips" select="/mlt/producer/property[(number($folderid) &gt; -1) and (@name = 'kdenlive:folderid') and (text() = $folderid)]/.. | /mlt/producer[(number($folderid) = -1) and not(property[@name='kdenlive:folderid'])]"/>
        <xsl:for-each select="$clips">
            <!-- Emulate to some extent how Kdenlive sorts its project bin elements,
                 especially clips; the name for which to sort is the clip name, if
                 explicitly set. If unset, then the clips basename+ext is used for
                 sorting. -->
            <xsl:sort select="concat(replace(property[@name='resource'],'.*/',''),property[@name='kdenlive:clipname'])" order="ascending"/>
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
                                    <xsl:value-of select="replace(property[@name='resource'],'.*/','')"/>
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


</xsl:stylesheet>
