<?xml version="1.0"?>
<!--
     Kdenlive Project XML Analyzer
     (c) 2016 Harald Albrecht

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
                xmlns:regexp="http://exslt.org/regular-expressions">
    
    <!-- Produce HTML5 document on an XSLT processor which does not
         support disable-output-escaping in order to generate the
         HTML5 !DOCTYPE. HTML5 thus defines a legacy doctype.
      -->
    <xsl:output method="html"
                doctype-system="about:legacy-compat"
                encoding="utf-8"
                indent="yes"/>
    
    <xsl:variable name="version" select="'0.8.1'"/>

    <!-- A short introduction to the structure of Kdenlive project
         documents...

    
         The MAINTRACTOR

         The main anchor is the <tractor> element that is present
         only once and is always uniquely identified as "maintractor".
         The maintractor is necessary due to underlying MLT engine design
         as the tractor is (simply spoken) making sure that frames get
         pulled from all "tracks" - hence its name.

         One important aspect of the tractor are the <tracks> it defines
         (see below for more details). MLT tracks actually do correspond
         with Kdenlive's tracks in the timeline. In the MLT model,
         tracks are represented through playlists.

         Another important aspect is that transitions do not live in
         tracks, but instead in the main tractor! This is a special
         design decision of MLT, and Kdenlive does a good job of
         hiding it - to the benefit of us user/editors.

         <tractor id="maintractor">
           <track producer="track-id"/> - references tracks (track playlists)
           <transition/>
         </tractor>

         Now it is time to introduce an important aspect of MLT, which is
         Kdenlive's multimedia engine: the specific way <tractor>s work in
         MLT. While MLT documents like to compare the <track>s (listed in
         a <tractor>) to layers in image processing programs, such as The
         Gimp, this simply is completely wrong. MLT tracks are not layers.

         In Gimp (and other such software), each layer contains an image
         and each such image may contain regions of transparency. Starting
         with the lowest layer each other layer is composited onto the
         lowest layer in some way. The simplest case is a normal blend,
         that takes transparency into calculation. However awkward this
         now may sound: each layer has an image, even if it is completely
         transparent. Please keep this in mind.

         Let's now turn to MLT and thus Kdenlive. Here, the <track>s form
         some kind of an abstract stack. The topmost item on this stack is
         a frame from the highest track at the current playhead position.

         Without further measures (that is, transitions) even if the frame
         on the highest track has transpareny, no other frame below in this
         stack will ever be visible. (!!!)


         MULTITRACK

         Just as a sidenote: Kdenlive leaves out the <multitrack> inside
         its "main bin" <tractor>.


         TRACKs

         Individual tracks are represented as MLT <playlist>s. However,
         please be aware that playlists are much more universal in that
         they are another type of producer (more on this later). So, not
         every <playlist> is going to represent a track. The only way to
         know which playlist actually is a track is through the main
         tractor.

         <playlist id="track-id">
         </playlist>


         BIN CLIPs

         In Kdenlive, ...
 
         Beneath the surface, MLT doesn't know about clips, but only
         producers.

         simple/playlist/tractor

         Kdenlive supports using either only video without audio, or audio
         without video from an audio/video clip, and of course using both.
         In order to implement audio-only and video-only from an audio/video
         clips, Kdenlive needs to deploy multiple producers for the same
         bin clip. The good news is that Kdenlive only creates such additional
         producers when it needs to do so.

         The <producer>s Kdenlive creates follow a certain naming scheme:
         * "id": for an audio/video or video source clip, where id is an integer
           "1", et cetera, assigned sequentially as clips are added to the
           project bin.
         * "id_ppp_audio": used for audio-only without the video from an
           audio/video clip. We'll come to the ppp part shortly.
         * "id_ppp_video": used for video-only without audio from an audio/video
           clip.

         
         PRODUCERs


         MLT service is "avformat-novalidate", ...


         ID Namespaces

         As we're dealing with a complex, non-hierarchical information model
         represented in simple hierarchical XML, identification of key elements
         and references to them plays a crucial role.

         For uniquely identifying key elements, Kdenlive and MLT rely on the
         XML builtin "id" attribute mechanism. When creating real-life id values,
         Kdenlive works along these "namespaces":

         * "1": identifies a clip <producer>. If this is an audio/video clip, then
           it will produce both audio and video; if this is an audio clip, it will
           only produce audio. ...

         * "1_playlistX":

         * "1_video": identifies a video-only <producer> for the bin clip with
             the id of "1". Technically, this producer has the audio index set
             to -1, that is, not using any audio "tracks".

         * "1_playlistX_audio": identifies an audio-only <producer> for the bin
             clip with the id of "1". Technically, this playlist has the video
             index is set to -1, that is, not using any video "tracks".
 
         * "playlist0": identifies a Kdenlive track in the form of an MLT
             <playlist>.

         * "maintractor":

         * "main bin":



         PRODUCER Types

         * avformat-novalidate
         * pixbuf
         * kdenlivetitle

      -->
    
    
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
                
                <style type="text/css">
                    body {
                        font-family: Arial, sans-serif;
                    }
                    
                    h2 {
                        margin-top: 2.5ex;
                        padding-bottom: 0.2ex;
                        border-bottom: solid #aaa 0.2ex;
                    }
                    
                    h3 {
                        max-width: 15em;
                        margin-top: 3ex;
                        padding-bottom: 0.2ex;
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
                        border-top: 1px dotted #aaa;
                        padding-top: .75ex;
                        padding-bottom: .75ex;
                        padding-left: 0.75em;
                        padding-right: 0.75em;
                    }
                    
                    ul.tracks li:last-child {
                        border-bottom: 1px dotted #aaa;
                    }
                    
                    li {
                        padding-top: 0.6ex;
                    }
                    
                    .error,
                    .warning {
                        font-weight: bolder;
                        color: #800;
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
                    
                </style>
            </head>
            <body>
                <h1>Kdenlive Project Analysis</h1>
                
                <p class="anno">Analysis script version: <xsl:value-of select="$version"/> / (c) Harald Albrecht</p>
                
                <!-- Sanity checks -->
                <!-- Not even remotely a Kdenlive project... -->
                <xsl:choose>
                    <xsl:when test="count(/mlt)!=1">
                        <p><b class="error">Error:</b> this is not a valid Kdenlive/MLT project; <xsl:value-of select="count(/mlt)"/> &lt;mlt&gt; element(s) found.</p>
                    </xsl:when>
                    <xsl:when test="/mlt/@producer!='main bin'">
                        <p><b class="error">Error:</b> this is not a valid Kdenlive project (MLT producer missing/invalid).</p>
                    </xsl:when>
                    <xsl:when test="number(/mlt/playlist[@id='main bin']/property[@name='kdenlive:docproperties.version'])&lt;0.94">
                        <p><b class="error">Error:</b> unsupported old Kdenlive project document version "<xsl:value-of select="/mlt/playlist[@id='main bin']/property[@name='kdenlive:docproperties.version']"/>"; can only analyze document from version 0.91 on and later.</p>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="analyze-kdenlive-project"/>
                    </xsl:otherwise>
                </xsl:choose>
            </body>
        </html>
    </xsl:template>
    
    <!-- Main logic -->
    <xsl:template name="analyze-kdenlive-project">
        <h2><i class="fa fa-info-circle" aria-hidden="true"/> General Project Information</h2>
        <xsl:call-template name="show-kdenlive-project-info"/>

        <h2><i class="fa fa-sitemap" aria-hidden="true"/> Project Bin Contents</h2>
        <p>All project bin clips, as organized into folders. Folders are purely a Kdenlive construct, whereas MLT doesn't know about and also doesn't need folders.</p>
        <xsl:call-template name="list-folders-of-folder">
            <xsl:with-param name="parentfolderid" select="-1"/>
        </xsl:call-template>

        <h2><i class="fa fa-bars" aria-hidden="true"/> Tracks Configuration</h2>
        <p>All the configured timeline tracks, from the topmost track down to the bottommost track in the timeline. Please note that MLT has a different understanding of topmost and bottommost: exactly the opposite of what we see in Kdenlive's timeline.</p>
        <xsl:call-template name="list-all-tracks"/>

        <h2><i class="fa fa-eye-slash" aria-hidden="true"/> Internally Added Track Transitions</h2>
        <p>Behind the scenes, Kdenlive does some MLT magic in order to achieve both sound mixing and video layer compositing across tracks. Thus, Kdenlive effectively hides some slightly nasty MLT peculiarities: for instance, unless explicitly told so, MLT won't ever mix audio from multiple (audio) tracks. This section may help in diagnosing slightly errartic Kdenlive projects with either odd audio mixing or odd video compositing.</p>
        <xsl:call-template name="video-compositing"/>
        <xsl:call-template name="audio-mixing"/>

        <h2><i class="fa fa-th" aria-hidden="true"/> Clip List</h2>
        <p>All project bin clips, flat, sorted by their names.</p>
        <xsl:call-template name="list-all-clips"/>
    </xsl:template>
    
    <!-- Display general information about this Kdenlive project.
      -->
    <xsl:template name="show-kdenlive-project-info">
        <xsl:variable name="project" select="/mlt/playlist[@id='main bin']"/>
        <xsl:variable name="docversion" select="$project/property[@name='kdenlive:docproperties.version']"/>
        <xsl:choose>
            <xsl:when test="$docversion">
                <table style="border-width:0;">
                    <tbody>
                        <xsl:call-template name="show-description-with-value">
                            <xsl:with-param name="description">Kdenlive project ID:</xsl:with-param>
                            <xsl:with-param name="select" select="$project/property[@name='kdenlive:docproperties.documentid']"/>
                        </xsl:call-template>
                        <xsl:call-template name="show-description-with-value">
                            <xsl:with-param name="description">Kdenlive project document version:</xsl:with-param>
                            <xsl:with-param name="select" select="$docversion"/>
                        </xsl:call-template>
                        <xsl:call-template name="show-description-with-value">
                            <xsl:with-param name="description">Created by Kdenlive version:</xsl:with-param>
                            <xsl:with-param name="select" select="$project/property[@name='kdenlive:docproperties.kdenliveversion']"/>
                        </xsl:call-template>
                        <xsl:call-template name="show-description-with-value">
                            <xsl:with-param name="description">Serialized by MLT version:</xsl:with-param>
                            <xsl:with-param name="select" select="/mlt/@version"/>
                        </xsl:call-template>
                        <xsl:call-template name="show-description-with-value">
                            <xsl:with-param name="description">Project folder:</xsl:with-param>
                            <xsl:with-param name="select" select="concat(/mlt/@root,'/',$project/property[@name='kdenlive:docproperties.projectfolder'])"/>
                        </xsl:call-template>
                        <xsl:call-template name="show-description-with-value">
                            <xsl:with-param name="description">Root folder:</xsl:with-param>
                            <xsl:with-param name="select" select="/mlt/@root"/>
                        </xsl:call-template>
                        <xsl:call-template name="show-description-with-value">
                            <xsl:with-param name="description">Locale to be used:</xsl:with-param>
                            <xsl:with-param name="select" select="/mlt/@LC_NUMERIC"/>
                        </xsl:call-template>
                        <xsl:call-template name="show-description-with-value">
                            <xsl:with-param name="description">Profile:</xsl:with-param>
                            <xsl:with-param name="select">
                                <xsl:value-of select="/mlt/profile/@width"/>&#215;<xsl:value-of select="/mlt/profile/@height"/>,
                                
                                <xsl:value-of select="/mlt/profile/@display_aspect_num"/>:<xsl:value-of select="/mlt/profile/@display_aspect_den"/>,
                                
                                <xsl:value-of select="/mlt/profile/@frame_rate_num"/>/<xsl:value-of select="/mlt/profile/@frame_rate_den"/> frames/s,
                                
                                <xsl:value-of select="/mlt/profile/@sample_aspect_num"/>:<xsl:value-of select="/mlt/profile/@sample_aspect_den"/> pixel aspect ratio
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="show-description-with-value">
                            <xsl:with-param name="description">Color space:</xsl:with-param>
                            <xsl:with-param name="select" select="/mlt/profile/@colorspace"/>
                        </xsl:call-template>
                    </tbody>
                </table>
            </xsl:when>
            <xsl:otherwise>
                <b>This does not seem to be a Kdenlive project document!</b>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Render a description with a value/selector in form of a table row
         consisting of exactly two columns: left col for description, right
         col for value.
      -->  
    <xsl:template name="show-description-with-value">
        <xsl:param name="select"/>
        <xsl:param name="description"/>
        <tr>
            <td><xsl:value-of select="$description"/></td>
            <td><xsl:value-of select="$select"/></td>
        </tr>
    </xsl:template>
    
    <!-- List all tracks
      -->
    <xsl:template name="list-all-tracks">
        <!-- Kdenlive's tracks are referenced as <tracks> elements inside the
             main <tractor> with id "maintractor". However, the Kdenlive
             tracks themselves are then represented as <playlists>. -->
        <xsl:variable name="tracks" select="/mlt/tractor[@id='maintractor']/track"/>
        <p><xsl:value-of select="count($tracks) - 1"/>(+1) timeline tracks:</p>
        <ul class="tracks">
            <xsl:for-each select="$tracks">
                <!-- reverse the order of track elements, thus being now in
                     order from bottom to top. This is necessary as MLT priorizes
                     its tracks in the reverse sequence. -->
                <xsl:sort select="position()" data-type="number" order="descending"/>
                <xsl:variable name="trackid" select="@producer"/>
                <xsl:variable name="mlttrackno">
                    <xsl:number format="1"/>
                </xsl:variable>
                
                <li>
                    <xsl:call-template name="show-track-info">
                        <xsl:with-param name="track" select="//playlist[@id=$trackid]"/>
                        <xsl:with-param name="hide" select="@hide"/>
                        <xsl:with-param name="no" select="position()"/>
                        <xsl:with-param name="trackno" select="$mlttrackno -1"/>
                    </xsl:call-template>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>
    
    
    <!-- Render track properties, such as track type, name, hidden, locked, muted, compositing
         
         * parameter track: the <playlist> node representing the track to be analysed.
         * parameter hide: if 1, then video is hidden for this track. The reason we need
             to pass in hide information separately is that the <playlist> doesn't contain
             this information. Instead, the <track> elements inside the "main bin"
             <tractor> specify whether video, audio, or both is hidden, if at all.
      -->
    <xsl:template name="show-track-info">
        <xsl:param name="track"/>
        <xsl:param name="hide"/>
        <xsl:param name="no"/>
        <xsl:param name="trackno"/>
        
        <!-- The track name and icon, but watch the builtin nameless black track! -->
        <xsl:choose>
            <xsl:when test="$track/property[@name='kdenlive:track_name']">
                <!-- Track type icon: video or audio; this information is found inside the
                     <playlist> track element.
                  -->
                <xsl:choose>
                    <xsl:when test="$track/property[@name='kdenlive:audio_track']">
                        <i class="fa fa-volume-up" aria-hidden="true" title="audio track #{$no}"/>&#160;
                    </xsl:when>
                    <xsl:otherwise>
                        <i class="fa fa-film" aria-hidden="true" title="video track #{$no}"/>&#160;
                    </xsl:otherwise>
                </xsl:choose>
                <!-- The user-visible track name -->
                <b><xsl:value-of select="$track/property[@name='kdenlive:track_name']"/></b>
            </xsl:when>
            <xsl:otherwise>
                <span class="anno" aria-hidden="true" title="builtin black track"><i class="fa fa-eye-slash"/>&#160;<i>hidden built-in</i>&#160;<b>black</b> track</span>
            </xsl:otherwise>
        </xsl:choose>
        &#160;
        
        <!-- Locked? -->
        <xsl:choose>
            <xsl:when test="$track/property[@name='kdenlive:locked_track']=1">
                <i class="fa fa-lock anno-locked" aria-hidden="true" title="locked"/>&#160;
            </xsl:when>
            <xsl:otherwise>
                <i class="fa fa-unlock anno-unlocked" aria-hidden="true" title="unlocked"/>&#160;
            </xsl:otherwise>
        </xsl:choose>

        <!-- Hidden video? -->
        <xsl:choose>
            <xsl:when test="$track/property[@name='kdenlive:audio_track']">
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$hide='video' or $hide='both'">
                        <i class="fa fa-eye-slash anno-hidden" aria-hidden="true" title="hidden"/>&#160;
                    </xsl:when>
                    <xsl:otherwise>
                        <i class="fa fa-eye anno-visible" aria-hidden="true" title="visible"/>&#160;
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        
        <!-- Muted? -->
        <xsl:choose>
            <xsl:when test="$hide='audio' or $hide='both'">
                <span class="anno-muted" aria-hidden="true" title="muted"><i class="fa fa-volume-off"/>&#215;</span>&#160;
            </xsl:when>
            <xsl:otherwise>
                <i class="fa fa-volume-up anno-audible" aria-hidden="true" title="audible"/>&#160;
            </xsl:otherwise>
        </xsl:choose>
            
        <!-- Video track compositing? -->
        <xsl:choose>
            <xsl:when test="$track/property[@name='kdenlive:audio_track']">
            </xsl:when>
            <xsl:otherwise>
                <!-- automatic composition needs an excplit invitation! -->
                <xsl:choose>
                    <xsl:when test="$track/property[@name='kdenlive:composite']=1">
                        <i class="fa fa-delicious anno-composite" aria-hidden="true" title="composite"/>&#160;
                    </xsl:when>
                    <xsl:otherwise>
                        <i class="fa fa-square-o anno-opaque" aria-hidden="true" title="opaque"/>&#160;
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        
        <!-- internal information -->
        <span class="anno-id"> (<i>track id: <xsl:value-of select="$track/@id"/>, MLT track index: <xsl:value-of select="$trackno"/></i>)</span>
    </xsl:template>
        
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
                            
                            <span class="anno-id"> (<i>clip id: <xsl:value-of select="$clipid"/></i>)</span>   
                        </xsl:otherwise>
                    </xsl:choose>
                </li>
            </xsl:if>
        </xsl:for-each>
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
                        <i class="fa fa-volume-up" aria-hidden="true" title="audio clip"/>&#160;
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
                                <span title="image sequence"><i class="fa fa-picture-o" aria-hidden="true"/>&#8201;<i class="fa fa-ellipsis-h" aria-hidden="true"/>&#8201;<i class="fa fa-picture-o" aria-hidden="true"/></span>&#160;
                            </xsl:when>
                            <xsl:otherwise>
                                <i class="fa fa-picture-o" aria-hidden="true" title="image clip"/>&#160;
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="property[@name='mlt_service']/text()='qimage'">
                        <i class="fa fa-picture-o" aria-hidden="true" title="image clip"/>&#160;
                    </xsl:when>
                    <!-- Kdenlive title clip -->
                    <xsl:when test="property[@name='mlt_service']/text()='kdenlivetitle'">
                        <i class="fa fa-font" aria-hidden="true" title="title clip"/>&#160;
                    </xsl:when>                                
                    <!-- MLT color clip -->
                    <xsl:when test="property[@name='mlt_service']/text()='color'">
                        <span style="font-size:50%; letter-spacing: -0.3em;" aria-hidden="true" title="color clip"><i class="fa fa-circle" style="color: #c00;"/><i class="fa fa-circle" style="color: #0c0;"/><i class="fa fa-circle" style="color: #00c;"/></span>&#160;
                    </xsl:when>       
                    <!-- MLT generators -->
                        <!-- t.b.d. -->
                    <!-- everything else, that is, a video clip (or so we think) -->
                    <xsl:otherwise>
                        <i class="fa fa-film" aria-hidden="true" title="video clip"/>&#160;
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
                            (<i>from folder</i>: <b><xsl:value-of select="$folder/text()"/></b>)
                        </xsl:if>

                        producer id: <xsl:value-of select="@id"/>
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
    <xsl:template name="video-compositing">
        <h3><i class="fa fa-film" aria-hidden="true"/><i class="fa fa-film" aria-hidden="true"/> Video Compositing</h3>
        
        <p>For automatic video track compositing, Kdenlives creates the following compositing transitions automatically behind the scenes.</p>

        <!-- Get all internally added transitions which are NOT audio mixers. This
             helps us with the different kind of compositing transitions currently
             used by Kdenlive. In particular:
             * frei0r.cairoblend
             * movit.###
             * qtblend
          -->
        <xsl:variable name="comptransitions" select="/mlt/tractor[@id='maintractor']/transition[property[@name='internal_added']/text()='237'][not(property[@name='mlt_service']/text()='mix')]"/>
        <xsl:variable name="trackscount" select="count(/mlt/tractor[@id='maintractor']/track)-1"/>

        <xsl:value-of select="count($comptransitions)"/> internally added automatic compositing transitions.
        
        <xsl:for-each select="$comptransitions">
            <!-- sort all implicitly added transitions by their a_track
                 parameter, so that we get groups of compositing. Yes,
                 the famous Muenchian method on the horizon...
              -->
            <xsl:sort select="property[@name='a_track']/text()" data-type="number" order="descending"/>

            <xsl:variable name="atrack" select="property[@name='a_track']"/>
            <xsl:variable name="compositetracksbyatrack" select="key('internal-composite-transition-by-a-track',$atrack)"/>

            <xsl:if test="generate-id() = generate-id($compositetracksbyatrack[1])">
                <!-- MLT transitions work on MLT track indices, which are 0-based,
                     bottom to top track. In order to later get the proper track
                     title we start with the B track MLT index for starters.
                  -->
                <xsl:variable name="atrackmltidx" select="number(property[@name='a_track']/text())"/>
                <!-- Next, get the track id, which is, by the way, something along
                     the lines of "playlist#". The track id allows us to locate the
                     <playlist> acting as a track.
                  -->
                <xsl:variable name="atrackid" select="/mlt/tractor[@id='maintractor']/track[$atrackmltidx+1]/@producer"/>
                <!-- Using the track id we can now look up the title as specified
                     inside the <playlist> track element, using one of the many
                     <property> child elements: the one being 'kdenlive:track_name'.
                  -->
                <xsl:variable name="atracktitle" select="/mlt/playlist[@id=$atrackid]/property[@name='kdenlive:track_name']/text()"/>
                
                <ul class="tracks">
                    <xsl:for-each select="$compositetracksbyatrack">
                        <xsl:sort select="property[@name='b_track']/text()" data-type="number" order="descending"/>

                        <!-- MLT transitions work on MLT track indices, which are 0-based,
                             bottom to top track. In order to later get the proper track
                             title we start with the B track MLT index for starters.
                          -->
                        <xsl:variable name="btrackmltidx" select="number(property[@name='b_track']/text())"/>
                        <!-- Next, get the track id, which is, by the way, something along
                             the lines of "playlist#". The track id allows us to locate the
                             <playlist> acting as a track.
                          -->
                        <xsl:variable name="btrackid" select="/mlt/tractor[@id='maintractor']/track[$btrackmltidx+1]/@producer"/>
                        <!-- Using the track id we can now look up the title as specified
                             inside the <playlist> track element, using one of the many
                             <property> child elements: the one being 'kdenlive:track_name'.
                          -->
                        <xsl:variable name="btracktitle" select="/mlt/playlist[@id=$btrackid]/property[@name='kdenlive:track_name']/text()"/>
                        <li>
                            <i class="fa fa-clone" aria-hidden="true" title="internally added mixing transition"/>&#160;&#160;
                            <xsl:choose>
                                <xsl:when test="property[@name='disable']/text() = '1'">
                                    <i class="fa fa-square-o anno-opaque"/>&#160;
                                </xsl:when>
                                <xsl:otherwise>
                                    <i class="fa fa-delicious anno-composite"/>&#160;
                                </xsl:otherwise>
                            </xsl:choose>
                            <b><xsl:value-of select="$btracktitle"/></b>
                            <span class="anno"> (<i>internal transition id: "<xsl:value-of select="@id"/>", MLT track indices B/A: <xsl:value-of select="$btrackmltidx"/>/<xsl:value-of select="$atrackmltidx"/></i>)</span>
                        </li>
                    </xsl:for-each>
                    <li>
                        <i class="fa fa-fast-forward fa-rotate-90" aria-hidden="true"/>&#160; onto <b><xsl:value-of select="$atracktitle"/></b>
                        <span class="anno"> (<i>MLT track index: <xsl:value-of select="$atrackmltidx"/></i>)</span>
                    </li>
                </ul>
            </xsl:if>

        </xsl:for-each>
        
    </xsl:template>

    
    
    
    <!-- Kdenlive's audio mixing happens in the background by adding the required
         MLT mix transitions.
      -->
    <xsl:template name="audio-mixing">
        <h3><i class="fa fa-volume-up" aria-hidden="true"/><i class="fa fa-volume-up fa-flip-horizontal" aria-hidden="true"/> Audio Mixing</h3>
        
        <p>For automatic audio mixing, Kdenlive creates the following mix transitions automatically behind the scenes. These mix transitions get updated by Kdenlive only when adding or removing tracks. They don't get automatically refreshed when loading a project (at least not at this time), so be careful in case they got out of sync.</p>
        
        <xsl:variable name="mixtransitions" select="/mlt/tractor[@id='maintractor']/transition[property[@name='internal_added']/text()='237'][property[@name='mlt_service']/text()='mix']"/>
        <xsl:variable name="trackscount" select="count(/mlt/tractor[@id='maintractor']/track)-1"/>
        
        <!-- Sanity check to quickly identify slightly insane Kdenlive projects -->
        <xsl:if test="$trackscount &lt; count($mixtransitions)">
            <p><span class="warning"><i class="fa fa-warning"/> Warning: </span>found <i>more</i> internally added audio mix transitions (<xsl:value-of select="count($mixtransitions)"/>) than actual tracks (<xsl:value-of select="$trackscount"/>) in project &#8211; this project may need some
                <xsl:if test="(count($mixtransitions) - $trackscount) &gt; 1">
                    <xsl:text> </xsl:text><b>serious</b>
                </xsl:if>
                <xsl:text> </xsl:text>XML cleanup.</p>
        </xsl:if>
        <xsl:if test="$trackscount &gt; count($mixtransitions)">
            <p><span class="warning"><i class="fa fa-warning"/> Warning: </span>not enough internally-added audio mix transitions found; there are more tracks (<xsl:value-of select="$trackscount"/>) than audio mixers (<xsl:value-of select="count($mixtransitions)"/>) in project &#8211; this project need its internally added mix transitions <b>rebuilt</b>, as audio mixing is currently incorrect.</p>
        </xsl:if>
        
        <p>
            <xsl:if test="not($trackscount=count($mixtransitions))">
                <span class="warning"><i class="fa fa-warning"/> Warning: </span>
            </xsl:if>
            <xsl:value-of select="count($mixtransitions)"/> internally added mix transitions (for <xsl:value-of select="$trackscount"/>+1 tracks):
        </p>
        
        <ul class="tracks">
            <!-- Iterate over all internally added(!) mix(!) transitions. Now this
                 is XPath galore...!
              -->
            <xsl:for-each select="$mixtransitions">
                <xsl:sort select="property[@name='b_track']/text()" data-type="number" order="descending"/>
                
                <!-- MLT transitions work on MLT track indices, which are 0-based,
                     bottom to top track. In order to later get the proper track
                     title we start with the B track MLT index for starters.
                  -->
                <xsl:variable name="trackmltidx" select="number(property[@name='b_track']/text())"/>
                <!-- Next, get the track id, which is, by the way, something along
                     the lines of "playlist#". The track id allows us to locate the
                     <playlist> acting as a track.
                  -->
                <xsl:variable name="trackid" select="/mlt/tractor[@id='maintractor']/track[$trackmltidx+1]/@producer"/>
                <!-- Using the track id we can now look up the title as specified
                     inside the <playlist> track element, using one of the many
                     <property> child elements: the one being 'kdenlive:track_name'.
                  -->
                <xsl:variable name="tracktitle" select="/mlt/playlist[@id=$trackid]/property[@name='kdenlive:track_name']/text()"/>
                <li>
                    <i class="fa fa-clone" aria-hidden="true" title="internally added mixing transition"/>&#160;
                    <i class="fa fa-volume-up" aria-hidden="true" title="internally added mixing transition"/>&#160;
                    <b><xsl:value-of select="$tracktitle"/></b>
                    <span class="anno"> (<i>internal transition id: "<xsl:value-of select="@id"/>", MLT track indices B/A: <xsl:value-of select="$trackmltidx"/>/<xsl:value-of select="number(property[@name='a_track']/text())"/></i>)</span>
                </li>
            </xsl:for-each>
            <li>
                <i class="fa fa-fast-forward fa-rotate-90" aria-hidden="true"/>&#160; onto internal hidden black_track
            </li>
        </ul>
    </xsl:template>

    
    
</xsl:stylesheet>