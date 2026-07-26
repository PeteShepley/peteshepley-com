// Rewrites extensionless request URIs to their index.html so pretty URLs
// (e.g. /blog/my-post/) resolve against the S3 REST origin, which has no
// concept of directory index resolution the way S3 website-hosting does.
function handler(event) {
  var request = event.request;
  var uri = request.uri;

  if (uri.endsWith('/')) {
    request.uri += 'index.html';
  } else if (!uri.includes('.')) {
    request.uri += '/index.html';
  }

  return request;
}
