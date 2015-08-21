Swim.HTML2ANSI =

  supportedColors:
    white        : '#fff'
    black        : '#000'
    red          : '#cd0000'
    green        : '#00cd00'
    yellow       : '#cdcd00'
    blue         : '#1e90ff'
    magenta      : '#cd00cd'
    cyan         : '#00cdcd'
    lightGrey    : '#e5e5e5'
    darkGrey     : '#4c4c4c'
    lightRed     : '#f00'
    lightGreen   : '#0f0'
    lightYellow  : '#ff0'
    lightBlue    : '#4682b4'
    lightMagenta : '#f0f'
    lightCyan    : '#0ff'

  colorSequences:
    white        : ['\x1B[39m', '\x1B[39m']
    black        : ['\x1B[30m', '\x1B[39m']
    red          : ['\x1B[31m', '\x1B[39m']
    green        : ['\x1B[32m', '\x1B[39m']
    yellow       : ['\x1B[33m', '\x1B[39m']
    blue         : ['\x1B[34m', '\x1B[39m']
    magenta      : ['\x1B[35m', '\x1B[39m']
    cyan         : ['\x1B[36m', '\x1B[39m']
    lightGrey    : ['\x1B[37m', '\x1B[39m']
    darkGrey     : ['\x1B[90m', '\x1B[39m']
    lightRed     : ['\x1B[91m', '\x1B[39m']
    lightGreen   : ['\x1B[92m', '\x1B[39m']
    lightYellow  : ['\x1B[93m', '\x1B[39m']
    lightBlue    : ['\x1B[94m', '\x1B[39m']
    lightMagenta : ['\x1B[95m', '\x1B[39m']
    lightCyan    : ['\x1B[96m', '\x1B[39m']

  bgColorSequences:
    white        : ['\x1B[107m', '\x1B[49m']
    black        : ['\x1B[40m', '\x1B[49m']
    red          : ['\x1B[41m', '\x1B[49m']
    green        : ['\x1B[42m', '\x1B[49m']
    yellow       : ['\x1B[43m', '\x1B[49m']
    blue         : ['\x1B[44m', '\x1B[49m']
    magenta      : ['\x1B[45m', '\x1B[49m']
    cyan         : ['\x1B[46m', '\x1B[49m']
    lightGrey    : ['\x1B[47m', '\x1B[49m']
    darkGrey     : ['\x1B[100m', '\x1B[49m']
    lightRed     : ['\x1B[101m', '\x1B[49m']
    lightGreen   : ['\x1B[102m', '\x1B[49m']
    lightYellow  : ['\x1B[103m', '\x1B[49m']
    lightBlue    : ['\x1B[104m', '\x1B[49m']
    lightMagenta : ['\x1B[105m', '\x1B[49m']
    lightCyan    : ['\x1B[106m', '\x1B[49m']

  styleSequences:
    bold          : ['\x1B[1m',  '\x1B[22m']
    italic        : ['\x1B[3m',  '\x1B[23m']
    underline     : ['\x1B[4m', '\x1B[24m']
    strikethrough : ['\x1B[9m',  '\x1B[29m']

  defaultStylesheet: """
    div, h1, h2, h3, h4, h5, h6, p, pre {
      display: block;
    }
    b, strong {
      font-weight: bold;
    }
    i, em {
      font-style: italic;
    }
    u {
      text-decoration: underline;
    }
    del, strike {
      text-decoration: strikethrough;
    }
    pre {
      white-space: pre;
    }
  """

  decode: (html, options = {}) ->
    self = Swim.HTML2ANSI

    if !self.nearestColor?
      i = 17
      ec = {}
      for c in Swim.ANSI.colors256
        ec[i++] = "##{_.padLeft(c.toString(16), 6, '0')}"
      self.nearestColor = require('nearest-color').from(self.supportedColors).or(ec)

    doc = Swim.$('<div></div>')

    if !options.css?
      options.css = []

    options.css.unshift(self.defaultStylesheet)
    for css in options.css
      doc[0].appendChild(Swim.$("<style>#{css}</style>")[0])

    doc[0].appendChild(Swim.$("<div>#{html}</div>")[0])

    buffer = self.outputChildren(doc[0])

    return buffer.join('')

  output: (node, options = {}) ->
    return [] if node.nodeName == 'STYLE' or node.nodeName == 'SCRIPT'
    self = Swim.HTML2ANSI

    buffer = []

    switch node.nodeName
      when 'A' then buffer = self.anchor(node, options)
      when 'P' then buffer = self.paragraph(node, options)
      when 'H1', 'H2', 'H3', 'H4' then buffer = self.heading(node, options)
      when 'BR' then buffer = self.lineBreak(node, options)
      when 'HR' then buffer = self.horizontalLine(node, options)
      when 'OL' then buffer = self.orderedList(node, options)
      when 'UL' then buffer = self.unorderedList(node, options)
      when 'PRE' then buffer = self.paragraph(node, _.extend({}, options, isInPre: true))
      when 'TABLE'
        if self.containsTable(node.attribs, options.tables)
          buffer = self.table(node, options)

    buffer = buffer.concat self.outputChildren(node, options)
    self.ensureLineBreakBetweenBlocks(node, buffer)

    return buffer

  outputChildren: (node, options = {}) ->
    self = Swim.HTML2ANSI
    buffer = []
    if node.childNodes.length
      for child in node.childNodes
        buffer = buffer.concat self.output(child, options)
    else if self.isTextNode(node)
      buffer.push self.applyStyle(node, options)
    return buffer

  getColorSequence: (name) ->
    self = Swim.HTML2ANSI
    sequence = self.colorSequences[name]
    if !sequence?
      sequence = ['\x1B[38;5;' + name + 'm', '\x1B[39m']
    return sequence

  getBGColorSequence: (name) ->
    self = Swim.HTML2ANSI
    sequence = self.bgColorSequences[name]
    if !sequence?
      sequence = ['\x1B[48;5;' + name + 'm', '\x1B[49m']
    return sequence

  applySequence: (lines, sequence, paddedWidth) ->
    lines.map (line) ->
      line = _.pad(line, paddedWidth) if paddedWidth
      sequence[0] + line + sequence[1]

  getStyle: (node) ->
    return {} if !node?
    self = Swim.HTML2ANSI
    view = node.ownerDocument.defaultView
    if self.isTextNode(node)
      node = node.parentNode
    return if self.isElement(node) then view.getComputedStyle(node) else {}

  findStyle: (node, property) ->
    return null if !node?
    self = Swim.HTML2ANSI
    view = node.ownerDocument.defaultView
    if self.isTextNode(node)
      node = node.parentNode
    style = view.getComputedStyle(node)
    while !style[property]?
      node = node.parentNode
      if !self.isElement(node)
        break
      style = view.getComputedStyle(node)
    return style[property]

  applyStyle: (node, options = {}) ->
    self = Swim.HTML2ANSI
    text = self.getText(node, options)

    switch self.findStyle(node, 'textTransform')
      when 'uppercase' then text = text.toUpperCase()
      when 'lowercase' then text = text.toLowerCase()
      when 'capitalize' then _.capitalize(text)

    lines = text.split('\n')
    maxLineLength = lines.reduce(((max, line) -> if line.length > max then line.length else max), 0)

    bgColor = self.findStyle(node, 'backgroundColor')
    if bgColor?
      bgColor = self.nearestColor(bgColor)
      if bgColor?
        bgSequence = self.getBGColorSequence(bgColor.name)
        lines = self.applySequence(lines, bgSequence, maxLineLength)

    color = self.findStyle(node, 'color')
    if color?
      color = self.nearestColor(color)
      if color?
        sequence = self.getColorSequence(color.name)
        lines = self.applySequence(lines, sequence)

    fontStyle = self.findStyle(node, 'fontStyle')
    if fontStyle == 'italic'
      lines = self.applySequence(lines, self.styleSequences.italic)

    fontWeight = self.findStyle(node, 'fontWeight')
    if fontWeight == 'bold'
      lines = self.applySequence(lines, self.styleSequences.bold)

    textDecoration = self.findStyle(node, 'textDecoration')
    if textDecoration == 'underline'
      lines = self.applySequence(lines, self.styleSequences.underline)
    else if textDecoration == 'strikethrough'
      lines = self.applySequence(lines, self.styleSequences.strikethrough)

    return lines.join('\n')

  isElement: (node) -> node?.nodeType == 1

  isTextNode: (node) -> node?.nodeType == 3

  isFirstChild: (node) -> node == node.parentNode.firstChild

  isLastChild:(node) -> node == node.parentNode.lastChild

  isBlockElement: (node) ->
    self = Swim.HTML2ANSI
    if self.isTextNode(node)
      return false
    self.getStyle(node).display == 'block'

  isBetweenBlocks: (node) ->
    self = Swim.HTML2ANSI
    self.isBlockElement(node.previousSibling) and self.isBlockElement(node.nextSibling)

  getText: (node, options = {}) ->
    self = Swim.HTML2ANSI

    # text = _.unescape(node.textContent)

    # if self.findStyle(node, 'whiteSpace') != 'pre'
    #   text = text.replace(/\s+/g, ' ')

    #   if self.isBetweenBlocks(node)
    #     text = text.replace(/^\s+|\s+$/g, '')
    #   else
    #     if self.isFirstChild(node)
    #       text = text.replace(/^\s+/, '')
    #     if self.isLastChild(node)
    #       text = text.replace(/\s+$/, '')

    text = if options.isInPre then node.textContent else _.trim(node.textContent)
    text = self.decodeHTMLEntities(text)
    return if options.isInPre then text else self.wordwrap((if node.needsSpace then ' ' + text else text), options.wordwrap)

  ensureLineBreakBetweenBlocks: (node, buffer) ->
    return if !node.nextSibling?
    self = Swim.HTML2ANSI
    return if !self.isBlockElement(node.previousSibling) and !self.isBlockElement(node.nextSibling)
    return if buffer.length == 0 or buffer[buffer.length - 1] == '\n'
    buffer.push '\n'

  lineBreak: (node, options) ->
    self = Swim.HTML2ANSI
    buffer = ['\n']
    buffer = buffer.concat(self.outputChildren(node, options))
    return buffer

  paragraph: (node, options) ->
    self = Swim.HTML2ANSI
    buffer = self.outputChildren(node, options)
    buffer.push "\n\n"
    return buffer

  heading: (node, options) ->
    self = Swim.HTML2ANSI
    buffer = _.map(self.outputChildren(node, options), (b) -> b.toUpperCase())
    buffer.push "\n"
    return buffer

  anchor: (node, options) ->
    self = Swim.HTML2ANSI
    href = ''
    buffer = []
    if node?
      buffer = [_.trim(self.outputChildren(node, options).join(''))]
      bt = buffer.join('')
    if !options.ignoreHref and node.attribs?.href
      href = node.attribs.href.replace(/^mailto\:/, '')
      if href? and options.linkHrefBaseUrl and href.indexOf('/') == 0
        href = options.linkHrefBaseUrl + href
        if !options.hideLinkHrefIfSameAsText or href != bt
          buffer.push " [#{href}]"
          bt = buffer.join('')
        return [self.getText({ textContent: (if _.isEmpty(bt) then href else bt), needsSpace: node.needsSpace }, options)]
    return buffer

  horizontalLine: (node, options) ->
    ["\n", _.repeat('-', options.wordwrap), "\n\n"]

  listItem: (prefix, node, options) ->
    self = Swim.HTML2ANSI
    options = _.clone(options)
    if options.wordwrap
      options.wordwrap -= prefix.length
    text = self.outputChildren(node, options).join('')
    text = text.replace(/\n/g, '\n' + _.repeat(' ', prefix.length))
    return [prefix, text, '\n']

  unorderedList: (node, options) ->
    self = Swim.HTML2ANSI
    buffer = []
    for n in node.childNodes
      buffer.push self.listItem(' * ', n, options).join('')
    buffer.push '\n'
    return buffer

  orderedList: (node, options) ->
    self = Swim.HTML2ANSI
    buffer = []
    if node.childNodes?.length
      maxLength = node.childNodes.length.toString().length
      for n, i in node.childNodes
        index = i + 1
        spacing = maxLength - index.toString().length
        prefix = ' ' + index + '. ' + _.repeat(' ', spacing)
        buffer.push self.listItem(prefix, node, options).joint('')
    buffer.push '\n'
    return buffer

  wordwrap: (text, max) ->
    result = if _.startsWith(text, ' ') then ' ' else ''
    words = _.words(text)
    length = result.length
    buffer = []
    for word in words
      if (max or max == 0) and length + word.length > max
        result += buffer.join(' ') + '\n'
        buffer.length = length = 0
      buffer.push word
      length += word.length + 1
    result += _.trimRight(buffer.join(' '))
    return result

  containsTable: (attr, tables) ->
    return true if tables == true

    removePrefix = (key) -> key.substr(1)

    checkPrefix = (prefix) -> (key) -> _.startsWith(key, prefix)

    filterByPrefix = (tables, prefix) ->
      _.chain(tables)
        .filter(checkPrefix(prefix))
        .map(removePrefix)
        .value()

    classes = filterByPrefix(tables, '.')
    ids = filterByPrefix(tables, '#')
    return attr and (_.include(classes, attr.class) or _.include(ids, attr.id))

  tableToString: (table) ->
    widths = _.map(table, (row) ->
      _.map(row, (col) ->
        col.length
      )
    )
    widths = _.zip(widths)
    widths = _.map(widths, (col) ->
      _.max(col)
    )

    buffer = []

    for row in table
      i = 0
      for col in row
        buffer.push _.padRight(_.trim(col), widths[i++], ' ') + '   '
      buffer.push "\n"

    buffer.push "\n"
    return buffer

  table: (node, options) ->
    self = Swim.HTML2ANSI
    table = []
    for n in node.childNodes
      tryParseRows(n)
    return self.tableToString(table)

    tryParseRows: (node) ->
      return if node.type != 'tag'

      if node.name == 'thead' or node.name == 'tbody' or node.name == 'tfoot'
        _.each(node.childNodes, tryParseRows)
        return

      if node.name != 'tr'
        return

      rows = []
      for n in node.childNodes
        if n.type == 'tag'
          if n.name == 'th'
            rows.push _.compact(self.heading(n, options).join('').split('\n'))
          else if n.name == 'td'
            rows.push _.compact(self.outputChildren(n, options).join('').split('\n'))
            if n.attribs?.colspan
              _.times(n.attribs.colspan - 1, ( -> rows.push [''] ))

      rows = _.zip(rows)
      for row in rows
        table.push _.map(row, ((col) -> col or ''))

  HTMLEntities:
    apos:0x0027, quot:0x0022, amp:0x0026, lt:0x003C, gt:0x003E, nbsp:0x00A0, iexcl:0x00A1, cent:0x00A2, pound:0x00A3,
    curren:0x00A4, yen:0x00A5, brvbar:0x00A6, sect:0x00A7, uml:0x00A8, copy:0x00A9, ordf:0x00AA, laquo:0x00AB,
    not:0x00AC, shy:0x00AD, reg:0x00AE, macr:0x00AF, deg:0x00B0, plusmn:0x00B1, sup2:0x00B2, sup3:0x00B3,
    acute:0x00B4, micro:0x00B5, para:0x00B6, middot:0x00B7, cedil:0x00B8, sup1:0x00B9, ordm:0x00BA, raquo:0x00BB,
    frac14:0x00BC, frac12:0x00BD, frac34:0x00BE, iquest:0x00BF, Agrave:0x00C0, Aacute:0x00C1, Acirc:0x00C2, Atilde:0x00C3,
    Auml:0x00C4, Aring:0x00C5, AElig:0x00C6, Ccedil:0x00C7, Egrave:0x00C8, Eacute:0x00C9, Ecirc:0x00CA, Euml:0x00CB,
    Igrave:0x00CC, Iacute:0x00CD, Icirc:0x00CE, Iuml:0x00CF, ETH:0x00D0, Ntilde:0x00D1, Ograve:0x00D2, Oacute:0x00D3,
    Ocirc:0x00D4, Otilde:0x00D5, Ouml:0x00D6, times:0x00D7, Oslash:0x00D8, Ugrave:0x00D9, Uacute:0x00DA, Ucirc:0x00DB,
    Uuml:0x00DC, Yacute:0x00DD, THORN:0x00DE, szlig:0x00DF, agrave:0x00E0, aacute:0x00E1, acirc:0x00E2, atilde:0x00E3,
    auml:0x00E4, aring:0x00E5, aelig:0x00E6, ccedil:0x00E7, egrave:0x00E8, eacute:0x00E9, ecirc:0x00EA, euml:0x00EB,
    igrave:0x00EC, iacute:0x00ED, icirc:0x00EE, iuml:0x00EF, eth:0x00F0, ntilde:0x00F1, ograve:0x00F2, oacute:0x00F3,
    ocirc:0x00F4, otilde:0x00F5, ouml:0x00F6, divide:0x00F7, oslash:0x00F8, ugrave:0x00F9, uacute:0x00FA, ucirc:0x00FB,
    uuml:0x00FC, yacute:0x00FD, thorn:0x00FE, yuml:0x00FF, OElig:0x0152, oelig:0x0153, Scaron:0x0160, scaron:0x0161,
    Yuml:0x0178, fnof:0x0192, circ:0x02C6, tilde:0x02DC, Alpha:0x0391, Beta:0x0392, Gamma:0x0393, Delta:0x0394,
    Epsilon:0x0395, Zeta:0x0396, Eta:0x0397, Theta:0x0398, Iota:0x0399, Kappa:0x039A, Lambda:0x039B, Mu:0x039C,
    Nu:0x039D, Xi:0x039E, Omicron:0x039F, Pi:0x03A0, Rho:0x03A1, Sigma:0x03A3, Tau:0x03A4, Upsilon:0x03A5,
    Phi:0x03A6, Chi:0x03A7, Psi:0x03A8, Omega:0x03A9, alpha:0x03B1, beta:0x03B2, gamma:0x03B3, delta:0x03B4,
    epsilon:0x03B5, zeta:0x03B6, eta:0x03B7, theta:0x03B8, iota:0x03B9, kappa:0x03BA, lambda:0x03BB, mu:0x03BC,
    nu:0x03BD, xi:0x03BE, omicron:0x03BF, pi:0x03C0, rho:0x03C1, sigmaf:0x03C2, sigma:0x03C3, tau:0x03C4,
    upsilon:0x03C5, phi:0x03C6, chi:0x03C7, psi:0x03C8, omega:0x03C9, thetasym:0x03D1, upsih:0x03D2, piv:0x03D6,
    ensp:0x2002, emsp:0x2003, thinsp:0x2009, zwnj:0x200C, zwj:0x200D, lrm:0x200E, rlm:0x200F, ndash:0x2013,
    mdash:0x2014, lsquo:0x2018, rsquo:0x2019, sbquo:0x201A, ldquo:0x201C, rdquo:0x201D, bdquo:0x201E, dagger:0x2020,
    Dagger:0x2021, bull:0x2022, hellip:0x2026, permil:0x2030, prime:0x2032, Prime:0x2033, lsaquo:0x2039, rsaquo:0x203A,
    oline:0x203E, frasl:0x2044, euro:0x20AC, image:0x2111, weierp:0x2118, real:0x211C, trade:0x2122, alefsym:0x2135,
    larr:0x2190, uarr:0x2191, rarr:0x2192, darr:0x2193, harr:0x2194, crarr:0x21B5, lArr:0x21D0, uArr:0x21D1,
    rArr:0x21D2, dArr:0x21D3, hArr:0x21D4, forall:0x2200, part:0x2202, exist:0x2203, empty:0x2205, nabla:0x2207,
    isin:0x2208, notin:0x2209, ni:0x220B, prod:0x220F, sum:0x2211, minus:0x2212, lowast:0x2217, radic:0x221A,
    prop:0x221D, infin:0x221E, ang:0x2220, and:0x2227, or:0x2228, cap:0x2229, cup:0x222A, "int":0x222B,
    there4:0x2234, sim:0x223C, cong:0x2245, asymp:0x2248, ne:0x2260, equiv:0x2261, le:0x2264, ge:0x2265,
    sub:0x2282, sup:0x2283, nsub:0x2284, sube:0x2286, supe:0x2287, oplus:0x2295, otimes:0x2297, perp:0x22A5,
    sdot:0x22C5, lceil:0x2308, rceil:0x2309, lfloor:0x230A, rfloor:0x230B, lang:0x2329, rang:0x232A, loz:0x25CA,
    spades:0x2660, clubs:0x2663, hearts:0x2665, diams:0x2666

  decodeHTMLEntities: (text) ->
    self = Swim.HTML2ANSI
    text.replace(/&(.+?);/g, (str, ent) ->
      if String.fromCharCode(ent[0]) != '#' then self.HTMLEntities[ent] else (if ent[1] == 'x' then parseInt(ent.substr(2), 16) else parseInt(ent.substr(1), 10))
    )
