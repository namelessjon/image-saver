(function (window, document, url, undefined) {
  // ignore the query!
  var source = ['//',window.location.host,window.location.pathname].join('');
  var win, desc, i, img = {}, title, titleLink, artist;
  if (document.getSelection) desc = document.getSelection();

  // rewrite this to use 'area' function?
  // might be smaller!
  var getLargestImage = function (images) {
    var image = images[0], imageSize = image.width * image.height;
    for (var i = 0; i < images.length; i ++) {
      var tSize = images[i].width * images[i].height;
      if (tSize > imageSize) {
        image = images[i];
        imageSize = tSize;
      }
    }
    return image;
  };
  i = getLargestImage(document.images);
  img.src = i.src;
  img.w   = i.width;
  img.h   = i.height;

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
  if (/cghub\.com/.test(source)) {
    var spec = $('h3.bcrumps a');
    artist = spec[1].innerHTML;
    title = spec[2].innerHTML;
    img.src = $('div.main-image a.full_size')[0].href;

  }
  if (/artstation\.com/.test(source)) {
    artist = $('.artwork-info .artist .name a').text();
    title  = $('h3.title').text();
    desc   = $('div.description').text();
  }
  var setFields = function (url, meta, image) {

    for (var field in meta) {
      if ((meta.hasOwnProperty(field))&&(meta[field] != undefined)) {
        url += field + '=' + encodeURIComponent(meta[field]) + "&";
      }
    }
    url += "i=" + encodeURIComponent(image.src) + "&";
    url += "w=" + (image.w || '0') + "&";
    url += "h=" + image.h || '0';
    return url;
  };
  url = setFields(url, {a:artist, t:title, d:desc, s:(window.location.protocol + source)}, img);

  void(window.open(url,'ImageSave','location=no,toolbar=no,width=500,height=500'));
})(window, window.document, 'http://localhost:8765/?')
