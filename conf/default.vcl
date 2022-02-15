vcl 4.0;
import directors;

backend webbackend {
  .host = "webbackend";
}

# Define the director that determines how to distribute incoming requests.
sub vcl_init {
  new bar = directors.fallback();
  bar.add_backend(webbackend);
}

sub vcl_recv {
set req.backend_hint = bar.backend();

  # Do not cache these paths.
  if (req.url ~ "^/status\.php$" ||
      req.url ~ "^/update\.php" ||
      req.url ~ "^/install\.php" ||
      req.url ~ "^/apc\.php$" ||
      req.url ~ "^/admin" ||
      req.url ~ "^/admin/.*$" ||
      req.url ~ "^/user" ||
      req.url ~ "^/user/.*$" ||
      req.url ~ "^/users/.*$" ||
      req.url ~ "^/info/.*$" ||
      req.url ~ "^/flag/.*$" ||
      req.url ~ "^.*/ajax/.*$" ||
      req.url ~ "^.*/ahah/.*$" ||
      req.url ~ "^/system/files/.*$") {

    return (pass);
  }

  # Always cache the following file types for all users. This list of extensions
  # appears twice, once here and again in vcl_fetch so make sure you edit both
  # and keep them equal.
  if (req.url ~ "(?i)\.(pdf|asc|dat|txt|doc|xls|ppt|tgz|csv|png|gif|jpeg|jpg|ico|swf|css|js)(\?.*)?$") {
    unset req.http.Cookie;
  }

  # Remove all cookies that Drupal doesn't need to know about. We explicitly
  # list the ones that Drupal does need, the SESS and NO_CACHE. If, after
  # running this code we find that either of these two cookies remains, we
  # will pass as the page cannot be cached.
  if (req.http.Cookie) {
    # 1. Append a semi-colon to the front of the cookie string.
    # 2. Remove all spaces that appear after semi-colons.
    # 3. Match the cookies we want to keep, adding the space we removed
    #    previously back. (\1) is first matching group in the regsuball.
    # 4. Remove all other cookies, identifying them by the fact that they have
    #    no space after the preceding semi-colon.
    # 5. Remove all spaces and semi-colons from the beginning and end of the
    #    cookie string.
    set req.http.Cookie = ";" + req.http.Cookie;
    set req.http.Cookie = regsuball(req.http.Cookie, "; +", ";");
    set req.http.Cookie = regsuball(req.http.Cookie, ";(SESS[a-z0-9]+|SSESS[a-z0-9]+|NO_CACHE)=", "; \1=");
    set req.http.Cookie = regsuball(req.http.Cookie, ";[^ ][^;]*", "");
    set req.http.Cookie = regsuball(req.http.Cookie, "^[; ]+|[; ]+$", "");

    if (req.http.Cookie == "") {
      # If there are no remaining cookies, remove the cookie header. If there
      # aren't any cookie headers, Varnish's default behavior will be to cache
      # the page.
      unset req.http.Cookie;
    }
    else {
      # If there is any cookies left (a session or NO_CACHE cookie), do not
      # cache the page. Pass it on to Apache directly.
      return (pass);
    }
  }
}

sub vcl_backend_response {
  # set Time to Live (TTL) for maximum cache lifetime
  set beresp.ttl = 120s;
}

sub vcl_backend_error {
  # Redirect to some other URL in the case of a homepage failure.
  #if (req.url ~ "^/?$") {
  #  set beresp.status = 302;
  #  set beresp.http.Location = "http://backup.example.com/";
  #}

  # Otherwise redirect to the homepage, which will likely be in the cache.
  set beresp.http.Content-Type = "text/html; charset=utf-8";
  synthetic( {"
<html>
<head>
  <title>Page Unavailable</title>
  <style>
    body { background: #500000; text-align: center; color: white; }
    #page { border: 1px solid #CCC; width: 500px; margin: 100px auto 0; padding: 30px; background: #323232; }
    a, a:link, a:visited { color: #CCC; }
    .error { color: #888; }
  </style>
</head>
<body onload="setTimeout(function() { window.location = '/' }, 5000)">
  <div id="page">
    <h1 class="title">Page Unavailable</h1>
    <p>The page you requested is temporarily unavailable.</p>
    <p>We're attempting to redirect you to the <a href="/">homepage</a> in 5 seconds.</p>
    <br/>
    <div class="error">(Varnish Error "} + beresp.status + " " + beresp.reason + {")</div>
  </div>
</body>
</html>
"} );
  return (deliver);
}


