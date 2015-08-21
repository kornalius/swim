{ Plugin } = Swim

String.prototype.camelize = -> _.camelize @valueOf()

String.prototype.capitalize = -> _.capitalize @valueOf()

String.prototype.chop = (steps) -> _.chop @valueOf(), steps

String.prototype.classify = -> _.classify @valueOf()

String.prototype.clean = -> _.clean @valueOf()

String.prototype.count = (substr) -> _.count @valueOf(), substr

String.prototype.startsWith = (substr) -> _.startsWith @valueOf(), substr

String.prototype.endsWith = (substr) -> _.endsWith @valueOf(), substr

String.prototype.escapeHTML = -> _.escapeHTML @valueOf()

String.prototype.humanize = -> _.humanize @valueOf()

String.prototype.isBlank = -> _.isBlank @valueOf()

String.prototype.lastIndexOf = (substr) -> _.lastIndexOf @valueOf(), substr

String.prototype.levenshtein = (substr) -> _.levenshtein @valueOf(), substr

String.prototype.lines = -> _.lines @valueOf()

String.prototype.lpad = (length, padstr) -> _.lpad @valueOf(), length, padstr

String.prototype.lrpad = (length, padstr) -> _.lrpad @valueOf(), length, padstr

String.prototype.pad = (length, padstr) -> _.pad @valueOf(), length, padstr

String.prototype.rpad = (length, padstr) -> _.rpad @valueOf(), length, padstr

String.prototype.reverse = -> _.reverse @valueOf()

oldReplace = String.prototype.replace
String.prototype.replace = (find, replace, ignorecase) -> oldReplace.call(@valueOf(), find, replace, (if ignorecase then 'i' else ''))

String.prototype.replaceAll = (find, replace, ignorecase) -> _.replaceAll(@valueOf(), find, replace, ignorecase)

String.prototype.ltrim = (characters) -> _.ltrim @valueOf(), characters

String.prototype.rtrim = (characters) -> _.rtrim @valueOf(), characters

String.prototype.trim = (characters) -> _.trim @valueOf(), characters

String.prototype.sprintf = (fmt, args...) -> _.sprintf @valueOf(), fmt, args...

String.prototype.surround = (wrapper) -> _.surround @valueOf(), wrapper

String.prototype.swapCase = -> _.swapCase @valueOf()

String.prototype.titleize = -> _.titleize @valueOf()

String.prototype.truncate = (length, truncate_str) -> _.truncate @valueOf(), length, truncate_str

String.prototype.uncamelcase = -> _.uncamelcase @valueOf()

String.prototype.uncapitalize = -> _.uncapitalize @valueOf()

String.prototype.undasherize = -> _.undasherize @valueOf()

String.prototype.unescapeHTML = -> _.unescapeHTML @valueOf()

String.prototype.underscore = -> _.underscore @valueOf()

String.prototype.unsurround = (wrapper) -> _.unsurround @valueOf(), wrapper

String.prototype.upper = -> _.upper @valueOf()

String.prototype.words = -> _.words @valueOf()
