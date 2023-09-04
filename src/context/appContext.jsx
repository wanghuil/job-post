'use client';

import { useContext, createContext, useReducer } from 'react';
import axios from 'axios';
import reducer from 'context/reducer';
import { addUserToLocalStorage } from 'context/utils';

const initialState = {
  user: undefined,
};

const AppContext = createContext(null);

export function AppProvider({ children }) {
  const [state, dispatch] = useReducer(reducer, initialState);

  const setupUser = async ({ currentUser, endPoint }) => {
    try {
      const { data } = await axios.post(
        `https://alb.land-tasker.link/api/v1/auth/${endPoint}`,
        currentUser,
      );

      const { user, token } = data;
      dispatch({
        type: 'SETUP_USER_SUCCESS',
        payload: user,
      });
      addUserToLocalStorage({ user, token });
    } catch (error) {
      console.log(error);
      dispatch({
        type: 'SETUP_USER_ERROR',
        payload: { msg: error.message },
      });
    }
  };
  return (
    <AppContext.Provider value={{
      ...state,
      setupUser,
    }}
    >
      {children}
    </AppContext.Provider>
  );
}

export const useAppContext = () => useContext(AppContext);
