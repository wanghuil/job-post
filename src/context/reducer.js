const reducer = (state, action) => {
  if (action.type === 'SETUP_USER_SUCCESS') {
    return {
      ...state,
      user: action.payload.user,
    };
  }

  if (action.type === 'SETUP_USER_ERROR') {
    return {
      ...state,
      user: undefined,
      alertMessage: action.payload.msg,
    };
  }

  throw new Error(`no such action: ${action.type}`);
};

export default reducer;
