import socket from "./socket"
import React from "react"
import ReactDOM from "react-dom"

class ProblemFinder extends React.Component{
  constructor(props) {
    super(props);
    // This binding is necessary to make `this` work in the callback
    this.handleAddProblemClick = this.handleAddProblemClick.bind(this)
    this.handleChange = this.handleChange.bind(this)
    this.handleKeyPress = this.handleKeyPress.bind(this)

    let problems = document.getElementsByClassName("original-problems")
    problems = Array.prototype.map.call(problems, (input) => {
      return {url: input.value, status: "done"}
    })

    this.state = {
      problemInput: "",
      problems: problems
    }

  } // close constructor

  componentDidMount(){
    let element = document.getElementById("contest-container")
    let userId = element.getAttribute("data-user-id")
    this.contestChannel = socket.channel("contest:"+ userId)

    this.contestChannel.on("job_processing", (resp) => {
      this.setState((prevState, props) => ({
        problems: prevState.problems.concat({url: resp.url, status: "processing"}),
      }))
    }) // close on job_processing channel event

    this.contestChannel.on("job_error", (resp) => {
      let problems = []
      this.state.problems.forEach((problem) => {
        if (problem.url == resp.url){
          let problem = {url: resp.url, status: "error"}
          problems.push(problem)
        }else{
          problems.push(problem)
        }
      })
      this.setState({problems: problems})
    })

    this.contestChannel.on("job_done", (resp) => {
      let problems = []
      this.state.problems.forEach((problem) => {
        if (problem.url == resp.url){
          let problem = {url: resp.url, status: "done"}
          problems.push(problem)
        }else{
          problems.push(problem)
        }
      })
      this.setState({problems: problems})
    }) // close on job_done channel event

    this.contestChannel.join()
      .receive("ok", resp => console.log("Joined the contest channel -> ", resp) )
      .receive("error", reason => console.log("Join failed ->", reason) )

  }

  render() {
    return (
      <div>
        <div className="col-md-9">
          <div className="form-group">
            <input type="text"
              className="form-control"
              value={this.state.problemInput}
              onKeyPress={this.handleKeyPress}
              onChange={this.handleChange}/>
          </div>
        </div>
        <div className="col-md-3">
          <a className="btn btn-primary"
            onClick={this.handleAddProblemClick}>Add problem</a>
        </div>
        <br />
        {this.renderProblems(this.state.problems)}
      </div>
    );
  }

  renderProblems(problems){
    let rows = []
    let i = 0
    this.state.problems.forEach((problem, index) => {
      rows.push(<ProblemInput value={problem.url} key={i} status={problem.status} handleRemove={this.handleRemove.bind(this, index)}/>)
      i = i + 1
    })
    return rows
  }

  handleKeyPress(event){
    if(event.key == "Enter"){
      event.preventDefault()
      this.handleAddProblemClick()
    }
  }

  handleChange(event){
    this.setState({problemInput: event.target.value});
  }

  handleAddProblemClick(){
    // handle when input is empty
    if (this.state.problemInput == "") return

    // handle when user adds 2 of the same urls
    if (this.state.problems.map((problem) => problem.url).includes(this.state.problemInput)){
      this.setState({problemInput: ""})
      return
    }

    let payload = {url: this.state.problemInput}
    this.contestChannel.push("new_problem", payload)
      .receive("error", e => console.log(e) )

    this.setState({problemInput: ""})
  }

  handleRemove(index){
    this.setState((prevState, props) => ({
      problems: prevState.problems.slice(0, index).concat(prevState.problems.slice(index + 1))
    }))
  } // close handleRemove
}

class ProblemInput extends React.Component {
  render() {
    return (
      <div className="form-group">
        <div className="col-md-9">
          <input className="form-control"
            name={this.ignoreInput(this.props.status)}
            value={this.props.value}
            readOnly />
          <p className="help-block">{this.statusText(this.props.status)}</p>
        </div>
        <div className="col-md-3">
          <a className="btn btn-danger" onClick={this.props.handleRemove}>Remove</a>
        </div>
      </div>
    )
  }

  ignoreInput(status) {
    if (status == "done")
      return "contest[problems][]"
    else
      return ""
  }

  statusText(status){
    if (status == "processing")
      return "Processing..."
    else if (this.props.status == "done")
      return "Done :)"
    else
      return "There was an error in processing"
  }
}

if(document.getElementsByClassName("problem-container").length > 0){
  ReactDOM.render(
    <ProblemFinder />,
    document.getElementsByClassName("problem-container")[0]
  );
}

export default ProblemFinder
