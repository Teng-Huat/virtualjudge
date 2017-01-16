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

// Allowing of file drop in problem page
if(document.getElementById('answer_body')!= null) {
  var holder = document.getElementById('answer_body'),
    state = document.getElementById('status');
  if (typeof window.FileReader === 'undefined') {
    state.className = 'fail';
  } else {
    state.className = 'success';
    state.innerHTML = 'File API & FileReader available';
  }
  holder.ondragover = function() {
    this.className = 'hover form-control';
    return false;
  };
  holder.ondragend = function() {
    this.className = 'form-control';
    return false;
  };
  holder.ondrop = function(e) {
    this.className = 'form-control';
    e.preventDefault();

    var file = e.dataTransfer.files[0],
      reader = new FileReader();
    reader.onload = function(event) {
      // console.log(event.target);
      holder.innerText = event.target.result;
    };
    // console.log(file);
    reader.readAsText(file);
    return false;
  };
}
