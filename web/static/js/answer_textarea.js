$('#answer_body').keydown(function (e) {

  if(e.keyCode===9){
    // tap pressed
    var v=this.value,s=this.selectionStart,e=this.selectionEnd;
    this.value=v.substring(0, s)+'\t'+v.substring(e);
    this.selectionStart=this.selectionEnd=s+1;
    return false;
  }

  if (e.ctrlKey && (e.keyCode == 13 || e.keyCode == 10)) {
    // Ctrl-Enter pressed
     $(this).closest('form').submit();
  }

});
