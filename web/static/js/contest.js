let Contest = {
  init(socket, element) { if (!element) {return}
    let userId = element.getAttribute("data-user-id")
    socket.connect()
    this.onReady(socket, userId)
  }, // close init
  onReady(socket, userId){

    let problemInput = document.getElementById("problem-input")
    let problemButton = document.getElementById("add-problem-btn")
    let problemInputContainer = document.getElementById("problem-inputs-ctn")

    let contestChannel = socket.channel("contest:"+ userId)
    // receive job done message
    contestChannel.on("job_processing", (resp) => {
      let formGroup = document.createElement("div")
      formGroup.classList.add("form-group")
      formGroup.classList.add("has-warning")
      let divColMd9 = document.createElement("div")
      divColMd9.classList.add("col-md-9")

      let divColMd3 = document.createElement("div")
      divColMd3.classList.add("col-md-3")

      let input = document.createElement("input")
      input.classList.add("form-control")
      input.setAttribute("readOnly", true)
      input.setAttribute("value", resp.url)

      let deleteBtn = document.createElement("a")
      deleteBtn.classList.add("btn")
      deleteBtn.classList.add("btn-danger")
      deleteBtn.appendChild(document.createTextNode("Remove"))

      let helpBlock = document.createElement("p")
      helpBlock.classList.add("help-block")
      helpBlock.textContent = "Processing.."

      deleteBtn.addEventListener("click", (e) =>{
        let formGroup = deleteBtn.parentNode.parentNode
        formGroup.parentNode.removeChild(formGroup)
      })

      problemInputContainer.appendChild(formGroup)

      // add input to formgroup
      formGroup.appendChild(divColMd9)
      divColMd9.appendChild(input)
      divColMd9.appendChild(helpBlock) // add help block

      // add delete button to formgroup
      formGroup.appendChild(divColMd3)
      divColMd3.appendChild(deleteBtn)

    })

    contestChannel.on("job_done", (resp) => {
      let inputs = problemInputContainer.getElementsByTagName("input")
      for (let input of inputs){
        let formGroup = input.parentNode.parentNode
        if(input.value == resp.url) {
          let helpBlock = formGroup.getElementsByClassName("help-block")[0]
          helpBlock.parentNode.removeChild(helpBlock) // remove the help block
          formGroup.classList.remove("has-warning")
          formGroup.classList.add("has-success")
          input.setAttribute("name", "contest[problems][]")
        } // close if
      } // close for loop
    }) // close on job_done channel event

    // join the channel
    contestChannel.join()
      .receive("ok", resp => console.log("Joined the contest channel -> ", resp) )
      .receive("error", reason => console.log("Join failed ->", reason) )

    // create events handler
    problemInput.addEventListener("keypress", (e) => {
      let key = e.which || e.keyCode;
      if (key !== 13) return
      e.preventDefault()
      this.addProblem(problemInput, contestChannel)
    })

    problemButton.addEventListener("click", (e) => {
      this.addProblem(problemInput, contestChannel)
    })

  },
  addProblem(problemInput, contestChannel){
    let payload = {url: problemInput.value}
    contestChannel.push("new_problem", payload)
      .receive("error", e => console.log(e) )
    problemInput.value = "" // clear the input
  }
} // close let Contest

export default Contest
