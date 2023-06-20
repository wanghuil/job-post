'use client';

import { useContext, createContext } from 'react';

const initialState = {
  user: 'test',
};

const AppContext = createContext(null);

export const AppProvider = ({ children }) => {
  <AppContext.Provider value={initialState}>
    {children}
  </AppContext.Provider>;
};

export const useAppContext = () => useContext(AppContext);
