import beautify_js from "js-beautify"

if(document.getElementsByClassName("beautify-html").length != 0){
  var textarea = document.getElementsByClassName("beautify-html")[0]
  textarea.value = beautify_js.html(textarea.value, { indent_size: 2 })
}
