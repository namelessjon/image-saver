// Javascript
var source = config.source;
var imageUrl = config.image;


var artist = null, title = null, desc = null;

var info;
  if (/deviantart\.com/.test(source)) {
    var links = document.links;
    for(i = 0; i < links.length; i++) {
      if ((links[i].href.indexOf(source) > -1) && (links[i].parentNode.nodeName == 'H1')) {
        titleLink = links[i];
        title = titleLink.textContent;
        break;
      }
    }
    artist = titleLink.parentNode.getElementsByClassName('u')[0].textContent;
    if (i = document.getElementById('download-button')) {
      img.src = i.href;
    }
  }

  if (/www\.artstation\.com/.test(source)) {
    artist = $('.artwork-info .artist .name a').text();
    title  = $('.artwork-info > h3').text();
    desc   = $('div.description').text();
  }

  if (/drawcrowd\.com/.test(source)) {
    title   = $.trim($('.project-title').text());
    artist  = $.trim($('span.project-user-name').text());
    desc    = $.trim($('div.overlay_project-description').text());
  }

info = {a:artist, t:title, d:desc};
info
