// Copyright (c) 2011 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/**
 * Returns a handler which will open a new window when activated.
 */

function setFields(url, meta, image) {

    for (var field in meta) {
      if ((meta.hasOwnProperty(field))&&(meta[field] != undefined)) {
        url += field + '=' + encodeURIComponent(meta[field]) + "&";
      }
    }
    url += "i=" + encodeURIComponent(image); // + "&";
  //  url += "w=" + (image.w || '0') + "&";
  //  url += "h=" + image.h || '0';
    return url;
};


function getClickHandler() {
  return function(info, tab) {
    // inject jquery ...
    chrome.tabs.executeScript(tab.id, {file:'jquery-3.1.1.slim.js'}, function () {
      // then some config information ...
      var config = "var config = " + JSON.stringify({source: info.pageUrl, imageUrl: info.srcUrl}) + ";";
      chrome.tabs.executeScript(tab.id, {code: config}, function () {
        // then actually do what we want to do
        chrome.tabs.executeScript(tab.id, {file: 'content.js'}, function (results) {
          console.log(results);
          results = results[0];

          var base = "http://localhost:8765/?";

          results.s = info.pageUrl;

          var url = setFields(base, results, info.srcUrl);

          // Create a new window to the info page.
          chrome.windows.create({ url: url, width: 520, height: 660, type: 'popup' });

        });
      })

    });



  };
};

/**
 * Create a context menu which will only show up for images.
 */
chrome.contextMenus.create({
  "title" : "Save Image",
  "type" : "normal",
  "contexts" : ["image"],
  "onclick" : getClickHandler()
});
