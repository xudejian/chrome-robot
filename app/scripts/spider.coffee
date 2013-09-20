#
#Find all links and frames on this page.
#@return {Array<string>} List of all urls.
#

get_urls = ->
  urls = a.href for a in document.getElementsByTagName('A')
  console.log urls

  # Finding frame URLs using window.frames doesn't work since
  # the framed windows haven't been loaded yet.
  if window.frames.length
    frames = document.getElementsByTagName 'FRAME'
    urls.push f.src for f in frames
    iframes = document.getElementsByTagName 'IFRAME'
    urls.push f.src for f in iframes
  urls

get_inline = ->
  # CSS and favicons.
  links = document.getElementsByTagName 'LINK'
  urls = link.href for link in links when link.href

  # Images
  imgs = document.getElementsByTagName 'IMG'
  urls.push img.src for img in imgs when img.src
  urls

get_scripts = ->
  # Scripts
  scripts = document.getElementsByTagName 'SCRIPT'
  urls = script.src for script in scripts when script.src
  # Embed
  embeds = document.getElementsByTagName 'EMBED'
  urls.push embed.src for embed in embeds when embed.src

  urls

chrome.runtime.sendMessage
  links: get_urls()
  inline: get_inline()
  scripts:get_scripts()
  url:document.location.href
