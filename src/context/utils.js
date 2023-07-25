const addUserToLocalStorage = ({ user, token }) => {
  localStorage.setItem('user', JSON.stringify(user));
  localStorage.setItem('token', token);
};

export { addUserToLocalStorage };
