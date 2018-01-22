<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:cm="top:marchand:xml"
  exclude-result-prefixes="xs math xd"
  version="3.0">

  <xsl:import href="demo:/demo/uppercase-elements.xsl"/>
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Nov 23, 2017</xd:p>
      <xd:p><xd:b>Author:</xd:b> cmarchand</xd:p>
      <xd:p></xd:p>
    </xd:desc>
  </xd:doc>
  
  
  <xsl:template match="text()">
    <xsl:value-of select="upper-case(.)"/>
  </xsl:template>
</xsl:stylesheet>