import React, {Component} from 'react';
import { render } from 'react-dom';
import { Provider } from 'react-redux'

import "phoenix_html"

import css from "../css/app.css"

import socket from "./socket"
import {store} from './store';
import Nodes from './Nodes';


const App = () => (
  <Provider store={store}>
    <Nodes/>
  </Provider>
)

const appEl = document.getElementById('app')

render(<App/>, appEl)

