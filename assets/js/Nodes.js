import React, {Fragment, Component} from 'react';
import {connect} from 'react-redux';

class Nodes extends Component {
  render() {
    return <div><h2>Active Nodes</h2>{
      this.props.active.map(node => (
        <Fragment key={node.id}>
          <div>Node: {node.id}</div>
          <div>Type: {node.type}</div>
        </Fragment>
      ))
    }</div>
  }
}

const mapStateToProps = (state) => ({
  active: state.nodes.active
})

export default connect(mapStateToProps)(Nodes)
