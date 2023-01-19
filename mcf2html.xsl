<xsl:stylesheet
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:x="my:x" exclude-result-prefixes="x"
  >

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:variable name="rounding" select="53"/>
  <!-- I use a 5mm grid and want all my photos snapped to it. Based on the value here, the XSL
       will output warning messages for photos where that's not the case. -->

  <xsl:variable name="year" select="number(substring(fotobook/@startdatecalendarium,7))"/>
  <xsl:variable name="daysInFeb" select="if (($year mod 4 = 0 and $year mod 100 !=0) or $year mod 400 = 0) then 29 else 28"/>
  <xsl:variable name="months">
    <months>
      <month key="1" name="Januar">31</month>
      <month key="2" name="Februar"><xsl:value-of select="$daysInFeb"/></month>
      <month key="3" name="März">31</month>
      <month key="4" name="April">30</month>
      <month key="5" name="Mai">31</month>
      <month key="6" name="Juni">30</month>
      <month key="7" name="Juli">31</month>
      <month key="8" name="August">31</month>
      <month key="9" name="September">30</month>
      <month key="10" name="Oktober">31</month>
      <month key="11" name="November">30</month>
      <month key="12" name="Dezember">31</month>
    </months>
  </xsl:variable>
  <xsl:key name="monthByNumber" match="month" use="string(@key)"/>

  <xsl:variable name="days">
    <days>
      <day key="0" name="So" />
      <day key="1" name="Mo" />
      <day key="2" name="Di" />
      <day key="3" name="Mi" />
      <day key="4" name="Do" />
      <day key="5" name="Fr" />
      <day key="6" name="Sa" />
    </days>
  </xsl:variable>
  <xsl:key name="dayByNumber" match="day" use="string(@key)"/>

  <xsl:variable name="fonts">
    <fonts>
      <font key="FranklinGothic" css="Franklin Gothic,ITC Franklin Gothic,Arial,sans-serif"/>
      <font key="CEWE Head" css="CEWE Head,Arial,sans-serif"/>
    </fonts>
  </xsl:variable>
  <xsl:key name="fontCSSByCode" match="font" use="string(@key)"/>

  <xsl:variable name="colors">
    <colors>
      <color key="Brown range of colors" pri="#fcf3e9" sec="#f6ddbe" ter="#cba65f"/>
    </colors>
  </xsl:variable>
  <xsl:key name="colorsByCode" match="color" use="string(@key)"/>

  <!-- Calendars are the same size on every page, but photobooks have a different first page because
       of the spine.  They also have multiple pagenr=0 entries.  afaict, everything only has a single
       pagenr=1 -->
  <xsl:variable name="page0Width" select="number(*/page[@pagenr='0'][@type='fullcover' or @type='calendarcoverfront'][1]/bundlesize/@width) div 10"/>
  <xsl:variable name="page0Height" select="number(*/page[@pagenr='0'][@type='fullcover' or @type='calendarcoverfront'][1]/bundlesize/@height) div 10"/>
  <xsl:variable name="pageWidth" select="number(*/page[@pagenr='1']/bundlesize/@width) div 10"/>
  <xsl:variable name="pageHeight" select="number(*/page[@pagenr='1']/bundlesize/@height) div 10"/>
  <xsl:variable name="imageDir" select="fotobook/@imagedir"/>

  <!-- When using a grid, pages are rooted in the centre.  This means there's always an even number
       of grid-sized blocks and a non-grid-sized block at the edges. Calculate the size of that block
       for left/right and top/bottom. -->
  <xsl:variable name="marginLR" select="(($pageWidth * 10) mod $rounding) div 2"/>
  <xsl:variable name="marginTB" select="(($pageHeight * 10) mod $rounding) div 2"/>

  <xsl:function name="x:dayOfWeek">
    <xsl:param name="y" />
    <xsl:param name="m" /> <!-- 1 <= m <= 12 -->
    <xsl:param name="d" /> <!-- Gregorian years only -->
    <xsl:variable name="ry" select="if ($m &lt; 3) then $y -1 else $y"/>
    <xsl:variable name="t">
      <xsl:choose>
	<xsl:when test="$m=1">0</xsl:when>
	<xsl:when test="$m=2">3</xsl:when>
	<xsl:when test="$m=3">2</xsl:when>
	<xsl:when test="$m=4">5</xsl:when>
	<xsl:when test="$m=5">0</xsl:when>
	<xsl:when test="$m=6">3</xsl:when>
	<xsl:when test="$m=7">5</xsl:when>
	<xsl:when test="$m=8">1</xsl:when>
	<xsl:when test="$m=9">4</xsl:when>
	<xsl:when test="$m=10">6</xsl:when>
	<xsl:when test="$m=11">2</xsl:when>
	<xsl:when test="$m=12">4</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="($ry + floor($ry div 4) - floor($ry div 100) + floor($ry div 400) + $t + $d) mod 7"/>
  </xsl:function>
  
  <xsl:template match="/fotobook">
    <xsl:message>
      page0Width <xsl:value-of select="$page0Width"/>
      page0Height <xsl:value-of select="$page0Height"/>
      pageWidth <xsl:value-of select="$pageWidth"/>
      pageHeight <xsl:value-of select="$pageHeight"/>
      marginLR <xsl:value-of select="$marginLR"/>
      marginTB <xsl:value-of select="$marginTB"/>
    </xsl:message>
    <html>
      <head>
	<title>Calendar</title>
	<style>
	  @page {
	  }
          @media print {
            @page :first {
              margin: 0;
	      size: <xsl:value-of select="$page0Width"/>mm <xsl:value-of select="$page0Height"/>mm;
            }
            @page {
              margin: 0;
	      size: <xsl:value-of select="$pageWidth"/>mm <xsl:value-of select="$pageHeight"/>mm;
	    }
	    body {
	      margin: 0;
	      -webkit-print-color-adjust: exact;
	    }
	  }
	  @media screen {
	    body {
	      margin: 0;
	      width: <xsl:value-of select="$pageWidth * 0.6"/>mm;
	      height: <xsl:value-of select="$pageHeight * 0.6"/>mm;
	    }
	  }
	  div.page {
	    position:relative;
	    page-break-after: always;
	    height: 100%;
	  }
	  span.year {
	    text-align:center;
	    position:absolute;
	    top:50%;
	    width:100%;
	    line-height:0;
	    font-size:48pt;
	  }
	  span.spinelogo {
	    background-color: red;
	    position:absolute;
	    width:100%;
	    height:100%;
	  }
	  div.misc {
	    position:absolute;
	    display:block;
	    text-align:center;
	  }
	  div.pic {
	    position:absolute;
	    display:block;
	  }
	  div.cal {
	    position:absolute;
	    display:block;
	  }
	  span.cal-onerow {
	    position:absolute;
	    top:30%;
	    width:100%;
	  }
	  td.daybox {
	    border:1px solid black;
	    text-align:center;
	    height: 3em;
	  }
	  span.cal-per-row {
	    position:absolute;
	    width:100%;
	    height:100%;
	  }
	  td.daybox-per-row {
	    text-align:right;
	  }
	</style>
	<script>
	  <xsl:text disable-output-escaping="yes">
function putImage(n) {
  let img = new Image();
  img.src = n.fn;
  img.onload = () => {
    let iw = img.naturalWidth;
    let ih = img.naturalHeight;
    if (n.top &lt; 0) {
      n.top = -n.top;
    }
    if (n.left &lt; 0) {
      n.left = -n.left;
    }
    let c = document.createElement('canvas');
    c.width = n.divw*2;
    c.height = n.divh*2;
    let ctx = c.getContext('2d');
    ctx.drawImage(img, n.left, n.top, n.areaw/n.scale, n.areah/n.scale, 0, 0, n.divw*2, n.divh*2);
    n.dst.src = c.toDataURL('image/jpeg');
    if (imgQueue.length > 0) {
      putImage(imgQueue.shift());
    } else {
      inFlight--;
      if (inFlight==0) {
        n.dst.onload= () => {
          window.print();
        }
      }
    }
  };
}

var imgQueue = [];
var inFlight = 5;
window.onload = function() {
  for (var i=0; i!=inFlight; i++) {
    putImage(imgQueue.shift());
  }
}
	  </xsl:text>
	</script>
      </head>
      <body>
	<xsl:apply-templates select="page" />
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="page">
    <div class="page">
      <xsl:apply-templates select="area">
	<xsl:sort select="round(@top * 100)" />
	<xsl:sort select="round(@left * 100)" />
      </xsl:apply-templates>
    </div>
  </xsl:template>

  <xsl:template match="area">
    <xsl:element name="div">
      <xsl:choose>
	<xsl:when test="image">
	  <xsl:attribute name="class">pic</xsl:attribute>
	</xsl:when>
	<xsl:when test="calendararea">
	  <xsl:attribute name="class">cal</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:attribute name="class">misc</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="pos" select="position|."/>
      <xsl:variable name="l">
	<xsl:choose>
	  <xsl:when test="$pos/@rotation='90' or $pos/@rotation='270'">
	    <xsl:value-of select="(($pos/@left+($pos/@width div 2)-($pos/@height div 2)) div ../bundlesize/@width)*100"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="($pos/@left div ../bundlesize/@width)*100"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
      <xsl:variable name="t">
	<xsl:choose>
	  <xsl:when test="$pos/@rotation='90' or $pos/@rotation='270'">
	    <xsl:value-of select="(($pos/@top+($pos/@height div 2) + $pos/@width - ($pos/@width div 2)) div ../bundlesize/@height)*100"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="($pos/@top div ../bundlesize/@height)*100"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
      <xsl:attribute name="style">
	<xsl:text>left: </xsl:text><xsl:value-of select="$l"/><xsl:text>%; </xsl:text>
	<xsl:text>top: </xsl:text><xsl:value-of select="$t"/><xsl:text>%; </xsl:text>
	<xsl:text>width: </xsl:text><xsl:value-of select="($pos/@width div ../bundlesize/@width)*100"/><xsl:text>%; </xsl:text>
	<xsl:text>height: </xsl:text><xsl:value-of select="($pos/@height div ../bundlesize/@height)*100"/><xsl:text>%; </xsl:text>
	<xsl:if test="$pos/@rotation='270'">
	  <xsl:text>transform-origin: 0 0; transform: rotate(270deg);</xsl:text>
	</xsl:if>
	<xsl:choose>
	  <xsl:when test="contains(text/textFormat/@Alignment,'ALIGNLEADING')">
	    <xsl:text>text-align: left;</xsl:text>
	  </xsl:when>
	  <xsl:when test="contains(text/textFormat/@Alignment,'ALIGNHCENTER')">
	    <xsl:text>text-align: center;</xsl:text>
	  </xsl:when>
	  <xsl:when test="contains(text/textFormat/@Alignment,'ALIGNTRAILING')">
	    <xsl:text>text-align: right;</xsl:text>
	  </xsl:when>
	</xsl:choose>
	<xsl:choose>
	  <xsl:when test="contains(text/textFormat/@Alignment,'ALIGNTOP')">
	    <xsl:text>vertical-align: top;</xsl:text>
	  </xsl:when>
	  <xsl:when test="contains(text/textFormat/@Alignment,'ALIGNVCENTER')">
	    <xsl:text>vertical-align: middle;</xsl:text>
	  </xsl:when>
	  <xsl:when test="contains(text/textFormat/@Alignment,'ALIGNBOTTOM')">
	    <xsl:text>vertical-align: bottom;</xsl:text>
	  </xsl:when>
	</xsl:choose>
      </xsl:attribute>
      <xsl:if test="@areatype='spinelogoarea'">
	<xsl:element name="span">
	  <xsl:attribute name="class">spinelogo</xsl:attribute>
	  <xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
	</xsl:element>
      </xsl:if>
      <xsl:apply-templates select="image"/>
      <xsl:apply-templates select="calendararea"/>
      <xsl:apply-templates select="text"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="image">
    <xsl:variable name="id" select="generate-id(.)"/>
    <xsl:variable name="fn" select="replace(@filename,'safecontainer:/','')"/>
    <xsl:element name="img">
      <xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
      <xsl:attribute name="title"><xsl:value-of select="$fn"/></xsl:attribute>
      <xsl:attribute name="width">100%</xsl:attribute>
      <xsl:attribute name="height">100%</xsl:attribute>
    </xsl:element>
    <xsl:variable name="ppos" select="../position|.."/>
    <xsl:variable name="cutoutTop">
      <xsl:choose>
	<xsl:when test="cutout">
	  <xsl:value-of select="cutout/@top div cutout/@scale"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="./@top"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="cutoutLeft">
      <xsl:choose>
	<xsl:when test="cutout">
	  <xsl:value-of select="cutout/@left div cutout/@scale"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="./@left"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="scale">
      <xsl:choose>
	<xsl:when test="cutout">
	  <xsl:value-of select="cutout/@scale"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="./@scale"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$rounding &gt; 0">
      <xsl:if test="(($ppos/@left - $marginLR) mod $rounding) &gt; 0.001 and (($ppos/@left - $marginLR) mod $rounding) &lt; ($rounding - 0.001)">
	<xsl:message>
	  Unrounded left <xsl:value-of select="$ppos/@left"/> for <xsl:value-of select="$fn"/>, remainder <xsl:value-of select="($ppos/@left - $marginLR) mod $rounding"/> on page <xsl:value-of select="ancestor::page/@pagenr"/>
	</xsl:message>
      </xsl:if>
      <xsl:if test="(($ppos/@top - $marginTB) mod $rounding) &gt; 0.001 and (($ppos/@top - $marginTB) mod $rounding) &lt; ($rounding - 0.001)">
	<xsl:message>
	  Unrounded top <xsl:value-of select="$ppos/@top"/> for <xsl:value-of select="$fn"/>, remainder <xsl:value-of select="($ppos/@top - $marginTB) mod $rounding"/> on page <xsl:value-of select="ancestor::page/@pagenr"/>
	</xsl:message>
      </xsl:if>
      <xsl:if test="($ppos/@width mod $rounding) &gt; 0.001 and ($ppos/@width mod $rounding) &lt; ($rounding - 0.001)">
	<xsl:message>
	  Unrounded width <xsl:value-of select="$ppos/@width"/> for <xsl:value-of select="$fn"/>, remainder <xsl:value-of select="$ppos/@width mod $rounding"/> on page <xsl:value-of select="ancestor::page/@pagenr"/>
	</xsl:message>
      </xsl:if>
      <xsl:if test="($ppos/@height mod $rounding) &gt; 0.001 and ($ppos/@height mod $rounding) &lt; ($rounding - 0.001)">
	<xsl:message>
	  Unrounded height <xsl:value-of select="$ppos/@height"/> for <xsl:value-of select="$fn"/>, remainder <xsl:value-of select="$ppos/@height mod $rounding"/> on page <xsl:value-of select="ancestor::page/@pagenr"/>
	</xsl:message>
      </xsl:if>
    </xsl:if>
    <script>
      i = document.getElementById('<xsl:value-of select="$id"/>');
      imgQueue.push({
        fn: "<xsl:value-of select="concat($imageDir,'/',$fn)"/>",
	dst: i,
	divw: i.parentNode.offsetWidth,
	divh: i.parentNode.offsetHeight,
	top: <xsl:value-of select="$cutoutTop"/>,
	left: <xsl:value-of select="$cutoutLeft"/>,
	areaw: <xsl:value-of select="$ppos/@width"/>,
	areah: <xsl:value-of select="$ppos/@height"/>,
	scale: <xsl:value-of select="$scale"/>
      });
    </script>
  </xsl:template>

  <xsl:template match="text">
    <xsl:element name="span">
      <xsl:attribute name="style">
	<!-- The text fields are complete embedded HTML documents, which seemed like a PITA to deal with.
             This hack avoids doing that, but does do two things:
             1. Extracts just the body style (which contains the font).
	     2. Changes references to CEWE's own "CEWE Head" font to specify sans-serif as a fallback. -->
	<xsl:value-of select="replace(replace(string(), '.*body style=&quot;([^&quot;]*)&quot;.*', '$1'),'''CEWE Head''','''CEWE Head'',sans-serif')"/>
	<xsl:text>position:absolute;</xsl:text>
	<xsl:if test="contains(textFormat/@Alignment,'ALIGNLEADING')">
	  <xsl:text>left:0;</xsl:text>
	</xsl:if>
	<xsl:if test="contains(textFormat/@Alignment,'ALIGNRIGHT')">
	  <xsl:text>right:0;</xsl:text>
	</xsl:if>
	<xsl:if test="contains(textFormat/@Alignment,'ALIGNTOP')">
	  <xsl:text>top:0;</xsl:text>
	</xsl:if>
	<xsl:if test="contains(textFormat/@Alignment,'ALIGNBOTTOM')">
	  <xsl:text>bottom:0;</xsl:text>
	</xsl:if>
      </xsl:attribute>
      <xsl:value-of disable-output-escaping="yes" select="replace(string(), '.*(&lt;span[^&lt;]*&lt;/span&gt;).*', '$1')"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="calendararea[@layoutschema='Year (Long-Name-Big)']">
    <xsl:variable name="font" select="key('fontCSSByCode', string(@font), $fonts)/@css"/>
    <div class="year">
    <xsl:element name="span">
      <xsl:attribute name="class">year</xsl:attribute>
      <xsl:attribute name="style">font-family: <xsl:value-of select="$font"/>; font-size:48pt; font-weight:bold;</xsl:attribute>
      <xsl:value-of select="$year" />
    </xsl:element>
    </div>
  </xsl:template>
  
  <xsl:template match="calendararea[@layoutschema='OneRow (gerry_03)']">
    <xsl:variable name="month" select="../../@pagenr"/>
    <xsl:variable name="numDays" select="key('monthByNumber', string($month), $months)"/>
    <xsl:variable name="dayWidth" select="100 div number($numDays)"/>
    <xsl:variable name="font" select="key('fontCSSByCode', string(@font), $fonts)/@css"/>
    <span class="cal-onerow">
      <xsl:element name="div">
	<xsl:attribute name="class">mName</xsl:attribute>
	<xsl:attribute name="style">font-family: <xsl:value-of select="$font"/>; font-size:36pt; font-weight:bold;</xsl:attribute>
	<xsl:value-of select="key('monthByNumber', string($month), $months)/@name"/>
      </xsl:element>
      <br />
      <table width="100%">
	<tr>
	  <xsl:for-each select="1 to $numDays">
	    <xsl:element name="td">
	      <xsl:attribute name="class">daybox</xsl:attribute>
	      <xsl:attribute name="style">font-family: <xsl:value-of select="$font"/>; font-size: 18;
	      <xsl:variable name="dow" select="x:dayOfWeek($year, $month, position())"/>
	      <xsl:if test="$dow=0 or $dow=6">font-weight: bold;</xsl:if>
	      </xsl:attribute>
	      <xsl:attribute name="width"><xsl:value-of select="$dayWidth"/>%</xsl:attribute>
	      <xsl:value-of select="position()"/>
	    </xsl:element>
	  </xsl:for-each>
	</tr>
      </table>
    </span>
  </xsl:template>
  
  <xsl:template match="calendararea[@layoutschema='Month']">
    <xsl:variable name="month" select="../../@pagenr"/>
    <xsl:variable name="font" select="key('fontCSSByCode', string(@font), $fonts)/@css"/>
    <xsl:variable name="colTer" select="key('colorsByCode', string(@colorschema), $colors)/@ter"/>
    <span class="cal-month">
      <xsl:element name="div">
	<xsl:attribute name="class">mName</xsl:attribute>
	<xsl:attribute name="style">font-family: <xsl:value-of select="$font"/>; font-size:36pt; font-weight:bold; color:<xsl:value-of select="$colTer"/>;</xsl:attribute>
	<xsl:value-of select="key('monthByNumber', string($month), $months)/@name"/>
      </xsl:element>
    </span>
  </xsl:template>

  <xsl:template match="calendararea[@layoutschema='OneDayPerRow (1)']">
    <xsl:variable name="month" select="../../@pagenr"/>
    <xsl:variable name="numDays" select="key('monthByNumber', string($month), $months)"/>
    <xsl:variable name="dayHeight" select="100 div number($numDays)"/>
    <xsl:variable name="font" select="key('fontCSSByCode', string(@font), $fonts)/@css"/>
    <xsl:variable name="colPri" select="key('colorsByCode', string(@colorschema), $colors)/@pri"/>
    <xsl:variable name="colSec" select="key('colorsByCode', string(@colorschema), $colors)/@sec"/>
    <xsl:variable name="colTer" select="key('colorsByCode', string(@colorschema), $colors)/@ter"/>
    <span class="cal-per-row">
      <table width="100%" height="100%" style="border:0; border-spacing:0;">
	<xsl:for-each select="1 to $numDays">
	  <xsl:variable name="dow" select="x:dayOfWeek($year, $month, position())"/>
	  <tr>
	    <xsl:element name="td">
	      <xsl:attribute name="class">daybox-per-row</xsl:attribute>
	      <xsl:attribute name="width">15%</xsl:attribute>
	      <xsl:attribute name="height"><xsl:value-of select="$dayHeight"/>%</xsl:attribute>
	      <xsl:attribute name="style">font-family: <xsl:value-of select="$font"/>; font-size: 18;
	      <xsl:if test="$dow=0">font-weight: bold;</xsl:if>
	      <xsl:if test="$dow=0 or $dow=6">background: <xsl:value-of select="$colSec"/>; </xsl:if>
	      <xsl:if test="not($dow=0 or $dow=6)">background: <xsl:value-of select="$colPri"/>; </xsl:if>
	      </xsl:attribute>
	      <xsl:value-of select="position()"/>
	    </xsl:element>
	    <xsl:element name="td">
	      <xsl:attribute name="class">daynamebox-per-row</xsl:attribute>
	      <xsl:attribute name="width">15%</xsl:attribute>
	      <xsl:attribute name="style">font-family: <xsl:value-of select="$font"/>; font-size 18; color:white; 
	      <xsl:if test="$dow=0">font-weight: bold;</xsl:if>
	      <xsl:if test="$dow=0 or $dow=6">background: <xsl:value-of select="$colTer"/>; </xsl:if>
	      <xsl:if test="not($dow=0 or $dow=6)">background: <xsl:value-of select="$colSec"/>; </xsl:if>
	      </xsl:attribute>
	      <xsl:value-of select="key('dayByNumber', string($dow), $days)/@name"/>
	    </xsl:element>
	    <xsl:element name="td">
	      <xsl:attribute name="class">blankbox-per-row</xsl:attribute>
	      <xsl:attribute name="width">70%</xsl:attribute>
	      <xsl:attribute name="style">padding:0;
	      <xsl:if test="$dow=0 or $dow=6">background: <xsl:value-of select="$colSec"/>; </xsl:if>
	      <xsl:if test="not($dow=0 or $dow=6)">background: <xsl:value-of select="$colPri"/>; </xsl:if>
	      </xsl:attribute>
	      <xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
	    </xsl:element>
	  </tr>
	</xsl:for-each>
      </table>
    </span>
  </xsl:template>
  
</xsl:stylesheet>
