import { ACTIVE_NODES } from './constants';

export const receiveActiveNodes = (nodes) => ({
  type: ACTIVE_NODES,
  payload: nodes
})
