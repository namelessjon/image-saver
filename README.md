# image-saver

Ruby app for saving pictures from the web, and annotating them with image-annotate

## Get started

1. Install the dependencies via bundler with `bundle install`
2. generate the bookmarklet code with `rake bookmarklet` (requires the uglifyjs npm module) and install it in the browser
3. To test, start the server with `ruby image_app.rb -s`
4. Go navigate to a page with an image, and save it!
