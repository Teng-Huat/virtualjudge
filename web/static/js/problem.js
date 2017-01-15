if(document.getElementById("problem-sandbox") != null) {
  var problemSandbox = document.getElementById("problem-sandbox")
  var problem = problemSandbox.srcdoc

  // create a url element
  var url = new URL(problemSandbox.src)
  var path = url.pathname.split("/")

  // remove last element(filename)
  // and filter out empty elements
  path = path.slice(0, -1).filter(String)

  // add url.origin(site name) to the first element)
  path.unshift(url.origin)

  var src = path.join("/")
  // replace everything that does not start with http:// with the path generated
  problem = problem.replace(/src="(?!\/)((?!https?:\/\/)[^\"]*)/g, "src=\""+ src +"/$1");

  // replace everything that is src="/... with src="http://url../..
  // basically src that starts with / will just be prepended with url.origin
  problem = problem.replace(/src="(\/[^\"]*)/g, "src=\""+ url.origin +"$1");
  problemSandbox.srcdoc = problem
}
