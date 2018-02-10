import React from 'react';
import ReactDOM from 'react-dom';
import { Button } from 'reactstrap';

export default function run_demo(root, channel) {
  ReactDOM.render(<Game channel={channel}/>, root);
}

// App state for Memory is:
// {
//     letters: Char Array,   // letter A-H
//     lastClicked: int,      // keep track of the index of last
//                            // clicked letter in the array
//     isDisabled: boolean,   // once a tile is clicked, all tile
//                            // button is disabled for 1s
//     isClicked: boolean Array, // the tile being clicked is set to true
//                               // used to change its ccs class
//     corrects: boolean Array,  // tiles matched are set to true
//                               // used to change its ccs class
//     scores: int,           // tracking the scores, every click on the
//                            // tile will deduct 1 point, find a match
//                            // will get 10 points.
// }

class Tile extends React.Component {

    render() {
        return (
            <button className = {this.props.correctness ? "tile-correct": this.props.isClicked? "tile2":"tile"}
                    disabled = {this.props.isDisabled}
                    onClick ={() => this.props.onClick()}>
                {this.props.value}
            </button>
        )
    }
}

class RestartButton extends React.Component {
    render() {
        return (
            <button onClick={() => this.props.onClick()}>
                Restart
            </button>
        )
    }
}

class Game extends React.Component {

    constructor(props) {
        super(props);
        this.channel = props.channel;
        this.channel.join()
                    .receive("ok", this.gotView.bind(this))
                    .receive("error", resp => { console.log("Unable to join", resp); });

        this.state = {
            letters: [],
            lastClicked: null,
            isDisabled: false,
            isClicked: [],
            corrects: [],
            count: 2,
            scores: 0,
        };
    }

    gotView(msg) {
        console.log("Got View", msg);
        this.setState(msg.view);
    }

    handleClick(i) {

        this.channel.push("clickTile", {index: i})
                    .receive("ok", this.gotView.bind(this));
        setTimeout(()=>{
                        this.channel.push("unDisable", {index: i})
                                    .receive("ok", this.gotView.bind(this));},750);

    }

    handleRestartClick() {

        this.channel.push("restart", {index: 1})
                    .receive("ok", this.gotView.bind(this));
    }

    renderTile(i) {
        return <Tile value={this.state.letters[i]}
                     onClick={() => this.handleClick(i)}
                     isDisabled={this.state.isDisabled}
                     isClicked={this.state.isClicked[i]}
                     correctness={this.state.corrects[i]}/>;
    }

    renderRestartButton() {
        return <RestartButton
            onClick={() => this.handleRestartClick()}/>;
    }

    render() {
        const scores = 'Scores: ' + this.state.scores;

        return (
            <div className="game-board">
                <div>{scores}</div>
                <div className="tile-table">
                    <table>
                        <tbody>
                        <tr>
                            <td>{this.renderTile(0)}</td>
                            <td>{this.renderTile(1)}</td>
                            <td>{this.renderTile(2)}</td>
                            <td>{this.renderTile(3)}</td>
                        </tr>
                        <tr>

                            <td>{this.renderTile(4)}</td>
                            <td>{this.renderTile(5)}</td>
                            <td>{this.renderTile(6)}</td>
                            <td>{this.renderTile(7)}</td>
                        </tr>
                        <tr>
                            <td>{this.renderTile(8)}</td>
                            <td>{this.renderTile(9)}</td>
                            <td>{this.renderTile(10)}</td>
                            <td> {this.renderTile(11)}</td>
                        </tr>
                        <tr>
                            <td>{this.renderTile(12)}</td>
                            <td> {this.renderTile(13)}</td>
                            <td> {this.renderTile(14)}</td>
                            <td>{this.renderTile(15)}</td>
                        </tr>
                        </tbody>
                    </table>
                </div>
                <div>{this.renderRestartButton()}</div>
                <p>Scores calculation: every click on the tile will deduct 1 point from the total score.<br/>
                    Find a match will get 10 points.</p>

            </div>
        );
    }
}
