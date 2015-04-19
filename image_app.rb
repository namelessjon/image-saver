require 'tilt/string'
require 'rack'
require 'open-uri'
require 'rack/singleshot'



class ImageApp
  attr_reader :template, :counter
  def initialize
    @template = Tilt::StringTemplate.new { ::DATA.read }
  end

  def call(env)
    request  = Rack::Request.new(env)
    response = Rack::Response.new

    unless request.path_info == '/'
      response.status = 404
      return response.finish

    end


    if request.get?
      locals = {:uri => uri(request), 'tags' => nil, 'a' => nil, 'd' => nil, 's' => nil, 't' => nil, 'i' => nil, 'w' => nil, 'h' => nil}.merge(request.GET)
      set_ratio(locals)
      if locals['t'] && !locals['t'].empty?
        locals['key'] = locals['t'].downcase.strip.gsub(/\s+/,"_").gsub(/\W+/,'')
      else
        locals['key'] = 'image'
      end


      response.write template.render(self, locals)
    elsif request.post?
      post = request.POST
      # just nuke bad params!
      post.delete_if { |k, v| v.nil? or v.empty? }
      src = post['i']
      return bad_request("No image\n#{post.inspect}") unless src
      begin
        image = open(src,
                   "User-Agent" => request.env['HTTP_USER_AGENT'],
                   "Referer"    => post['s'] || src,
                   "Accept-Encoding" => 'identity'
                  )
        img = image.read
      rescue OpenURI::HTTPError => e
        bad_request(image.read)
      end

      # set source from the image path
      post['s'] ||= src


      command = [ENV['ANNOTATE_SCRIPT'] || 'image_annotate.py']
      %w{a d s t}.each do |param|
        if post.has_key?(param)
          command << "-#{param}"
          command << post[param]
        end
      end
      if post.has_key?('Tags')
        post['Tags'].split(',').map(&:to_s).each do |tag|
          tag.strip!
          command << '-T' << tag unless tag.empty?
        end
      end
      command << '-n' # no gui
      command << '-o'
      command << filename(src, post['key'] || 'image')

      r, w = IO.pipe
      re, we = IO.pipe
      pid = Process.spawn(*command, :in => r, :out => we, :err => we, :chdir => (ENV['DOWNLOAD_DIR'] || File.join(ENV['HOME'], "Downloads")))
      r.close
      we.close
      w.write(img)
      w.close
      err = re.read
      pid, status = Process.waitpid2(pid)
      return bad_request("#{err.inspect}") if status.exitstatus != 0
      response.write('<html><body><script>window.close();</script></body></html>')
    else
      response.status = 405
    end
    response.finish
  rescue Exception => e
    bad_request("#{e.class} - #{e.inspect}")
  end

  def bad_request(reason="Bad request")
    response = Rack::Response.new
    response.status = 400
    response.write(reason)
    response.finish
  end

  def filename(imagename, key='image')
    ext = File.extname(imagename).gsub(/\?\d+$/,'')
    date = Time.now.strftime('%Y%m%d_%H%M%S')
    type = "I1.3"
    key = "#{key}#{ext}"
    [date, type, key].join("-")
  end

  def set_ratio(locals)
    locals['h'] = locals['h'].to_i
    locals['w'] = locals['w'].to_i
    if locals['w'] > 0 and locals['h'] > 0
      if locals['w'] > locals['h']
        locals['wi'] = 200
        locals['hi'] = ((200.to_f/locals['w']) * locals['h']).to_i
      else
        locals['hi'] = 200
        locals['wi'] = ((200.to_f/locals['h']) * locals['w']).to_i
      end
    else
      locals['hi'] = locals['wi'] = 200
    end
  end

  def ratio(size, width, height)
  end

  # Generates the absolute URI for a given path in the app.
  # Takes Rack routers and reverse proxies into account.
  def uri(request, addr = nil)
    uri = [host = ""]

    host << "http#{'s' if request.ssl?}://"
    if request.port != (request.ssl? ? 443 : 80)
      host << request.host_with_port
    else
      host << request.host
    end

    uri << request.script_name.to_s 
    uri << (addr ? addr : request.path_info).to_s
    File.join uri
  end
end




if $0 == __FILE__
  handler, handler_opts = nil, {}
  builder = Rack::Builder.new
  builder.run ImageApp.new
  test = ARGV.first == '-t' ? true : false

  if test
    handler      = Rack::Handler.get('webrick')
    handler_opts = {Port: 8765, Host: '127.0.0.1'}
  else
    handler = Rack::Handler.get('singleshot')
  end

  handler.run builder, handler_opts do |server|
    [:INT, :TERM].each { |sig| trap(sig) { server.respond_to?(:stop!) ? server.stop! : server.stop } }
  end
end


__END__
<html>
<head>
<title>Image Server</title>
<style type='text/css'>
label {
  display: inline-block;
  width: 20%;
}
input[type=text] {
  width: 75%;
}
</style>
</head>
<body>
<img src='#{i}' width='#{wi}' height='#{hi}' />
<p>#{w}x#{h}</p>
<form method='POST' action='#{uri}'>
<label for='i'>Image:</label><input type='text' value='#{i}' name='i' /><br />
<label for='t'>Title:</label><input type='text' value='#{t}' name='t' /><br />
<label for='a'>Artist:</label><input type='text' value='#{a}' name='a' /><br />
<label for='d'>Desc:</label><input type='text' value='#{d}' name='d' size='2000' /><br />
<label for='s'>Source:</label><input type='text' value='#{s}' name='s' /><br />
<label for='Tags'>Tags:</label><input type='text' value='#{tags || nil}' name='Tags' /><br />
<label for='key'>Key:</label><input type='text' value='#{key}' name='key' /><br />
<input type='submit' value='Save'/>
</form>
</body>
</html>
