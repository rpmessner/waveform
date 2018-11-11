import { combineReducers, createStore } from 'redux';
import {ACTIVE_NODES} from './constants';

const InitialState = {
  active: []
}

const nodes = (state = InitialState, action) => {
  switch (action.type) {
    case ACTIVE_NODES:
      const newState = {...state, active: action.payload.nodes }
      console.log('action', state, action, newState)
      return newState;
    default:
      return state
  }
}

const reducer = combineReducers({
  nodes,
})

export const store = createStore(reducer);
export const {dispatch} = store;
