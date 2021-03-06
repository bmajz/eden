<?xml version="1.0"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <!-- **********************************************************************
         WFS Layers - CSV Import Stylesheet

         CSV column...........Format..........Content

         Name.................string..........Layer Name
         URL..................string..........Layer URL
         Description..........string..........Layer Description
         Source Name..........string..........Layer Source Name
         Source URL...........string..........Layer Source URL
         Projection............string.........Layer Projection (mandatory)
         Marker...............string..........Layer Symbology Marker Name
         Style................string..........Layer Style
         Feature Type.........string..........Layer Feature Type (mandatory)
         Feature Namespace....string..........Layer Feature Namespace (optional)
         Title................string..........Layer Title
         Geometry Name........string..........Layer Geometry Name
         Config...............string..........Configuration Name
         Folder...............string..........Layer Folder
         Enabled..............boolean.........Layer Enabled in config? (SITE_DEFAULT if not-specified)
         Visible..............boolean.........Layer Visible in config? (SITE_DEFAULT if not-specified)
         Cluster Attribute....string..........Layer Cluster Attribute: The attribute to use for clustering
         Cluster Distance.....integer.........Layer Cluster Distance: The number of pixels apart that features need to be before they are clustered (default=20)
         Cluster Threshold....integer.........Layer Cluster Threshold: The minimum number of features to form a cluster (default=2)
         Refresh..............integer.........layer Refresh (Number of seconds between refreshes: 0 to disable)

    *********************************************************************** -->
    <xsl:output method="xml"/>

    <!-- ****************************************************************** -->
    <!-- Indexes for faster processing -->
    <xsl:key name="configs" match="row" use="col[@field='Config']/text()"/>
    <xsl:key name="layers" match="row" use="col[@field='Name']/text()"/>
    <xsl:key name="markers" match="row" use="col[@field='Marker']/text()"/>
    <xsl:key name="projections" match="row" use="col[@field='Projection']/text()"/>

    <!-- ****************************************************************** -->
    <xsl:template match="/">
        <s3xml>
            <!-- Configs -->
            <xsl:for-each select="//row[generate-id(.)=generate-id(key('configs',
                                                                   col[@field='Config'])[1])]">
                <xsl:call-template name="Config"/>
            </xsl:for-each>

            <!-- Projections -->
            <xsl:for-each select="//row[generate-id(.)=generate-id(key('projections',
                                                                   col[@field='Projection'])[1])]">
                <xsl:call-template name="Projection"/>
            </xsl:for-each>

            <!-- Layers -->
            <xsl:for-each select="//row[generate-id(.)=generate-id(key('layers',
                                                                   col[@field='Name'])[1])]">
                <xsl:call-template name="Layer"/>
            </xsl:for-each>

            <!-- Markers -->
            <xsl:for-each select="//row[generate-id(.)=generate-id(key('markers',
                                                                   col[@field='Marker'])[1])]">
                <xsl:call-template name="Marker"/>
            </xsl:for-each>

        </s3xml>
    </xsl:template>

    <!-- ****************************************************************** -->
    <xsl:template name="Config">

        <xsl:variable name="Config" select="col[@field='Config']/text()"/>
    
        <resource name="gis_config">
            <xsl:attribute name="tuid">
                <xsl:value-of select="$Config"/>
            </xsl:attribute>
            <data field="name"><xsl:value-of select="$Config"/></data>
        </resource>
    </xsl:template>

    <!-- ****************************************************************** -->
    <xsl:template name="Layer">

        <xsl:variable name="Config" select="col[@field='Config']/text()"/>
        <xsl:variable name="Marker" select="col[@field='Marker']/text()"/>
        <xsl:variable name="Projection" select="col[@field='Projection']/text()"/>

        <resource name="gis_layer_wfs">
            <data field="name"><xsl:value-of select="col[@field='Name']"/></data>
            <data field="description"><xsl:value-of select="col[@field='Description']"/></data>
            <data field="source_name"><xsl:value-of select="col[@field='Source Name']"/></data>
            <data field="source_url"><xsl:value-of select="col[@field='Source URL']"/></data>
            <data field="url"><xsl:value-of select="col[@field='URL']"/></data>
            <xsl:if test="col[@field='Refresh']!=''">
                <data field="refresh"><xsl:value-of select="col[@field='Refresh']"/></data>
            </xsl:if>
            <xsl:if test="col[@field='Cluster Attribute']!=''">
                <data field="cluster_attribute"><xsl:value-of select="col[@field='Cluster Attribute']"/></data>
            </xsl:if>
            <reference field="projection_id" resource="gis_projection">
                <xsl:attribute name="tuid">
                    <xsl:value-of select="$Projection"/>
                </xsl:attribute>
            </reference>
            <data field="featureType"><xsl:value-of select="col[@field='Feature Type']"/></data>
            <xsl:if test="col[@field='Feature Namespace'] != ''">
                <data field="featureNS"><xsl:value-of select="col[@field='Feature Namespace']"/></data>
            </xsl:if>
            <xsl:if test="col[@field='Title'] != ''">
                <data field="title"><xsl:value-of select="col[@field='Title']"/></data>
            </xsl:if>
            <xsl:if test="col[@field='Geometry Name'] != ''">
                <data field="geometryName"><xsl:value-of select="col[@field='Geometry Name']"/></data>
            </xsl:if>

            <resource name="gis_layer_config">
                <reference field="config_id" resource="gis_config">
                    <xsl:choose>
                        <xsl:when test="$Config!=''">
                            <xsl:attribute name="tuid">
                                <xsl:value-of select="$Config"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="uuid">
                                <xsl:value-of select="'SITE_DEFAULT'"/>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                </reference>
                <xsl:if test="col[@field='Folder']!=''">
                    <data field="dir"><xsl:value-of select="col[@field='Folder']"/></data>
                </xsl:if>
                <data field="enabled"><xsl:value-of select="col[@field='Enabled']"/></data>
                <data field="visible"><xsl:value-of select="col[@field='Visible']"/></data>
            </resource>

            <resource name="gis_style">
                <!-- @ToDo: Allow restricting the style to a specific Config
                <xsl:if test="$Config!=''">
                    <reference field="config_id" resource="gis_config">
                        <xsl:attribute name="tuid">
                            <xsl:value-of select="$Config"/>
                        </xsl:attribute>
                    </reference>
                </xsl:if> -->
                <xsl:if test="$Marker!=''">
                    <reference field="marker_id" resource="gis_marker">
                        <xsl:attribute name="tuid">
                            <xsl:value-of select="$Marker"/>
                        </xsl:attribute>
                    </reference>
                </xsl:if>
                <xsl:if test="col[@field='Opacity']!=''">
                    <data field="opacity"><xsl:value-of select="col[@field='Opacity']"/></data>
                </xsl:if>
                <xsl:if test="col[@field='Popup Format']!=''">
                    <data field="popup_format"><xsl:value-of select="col[@field='Popup Format']"/></data>
                </xsl:if>
                <xsl:if test="col[@field='Style']!=''">
                    <data field="style"><xsl:value-of select="col[@field='Style']"/></data>
                </xsl:if>
                <xsl:if test="col[@field='Cluster Distance']!=''">
                    <data field="cluster_distance"><xsl:value-of select="col[@field='Cluster Distance']"/></data>
                </xsl:if>
                <xsl:if test="col[@field='Cluster Threshold']!=''">
                    <data field="cluster_threshold"><xsl:value-of select="col[@field='Cluster Threshold']"/></data>
                </xsl:if>
            </resource>

        </resource>
    </xsl:template>

    <!-- ****************************************************************** -->
    <xsl:template name="Marker">

        <xsl:variable name="Marker" select="col[@field='Marker']/text()"/>
    
        <resource name="gis_marker">
            <xsl:attribute name="tuid">
                <xsl:value-of select="$Marker"/>
            </xsl:attribute>
            <data field="name"><xsl:value-of select="$Marker"/></data>
        </resource>
    </xsl:template>

    <!-- ****************************************************************** -->
    <xsl:template name="Projection">

        <xsl:variable name="Projection" select="col[@field='Projection']/text()"/>
    
        <resource name="gis_projection">
            <xsl:attribute name="tuid">
                <xsl:value-of select="$Projection"/>
            </xsl:attribute>
            <data field="epsg"><xsl:value-of select="$Projection"/></data>
        </resource>
    </xsl:template>

    <!-- ****************************************************************** -->

</xsl:stylesheet>
