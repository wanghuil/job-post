'use client';

import { useState } from 'react';
import Logo from 'components/Logo/Logo';
import Card from 'components/Card/Card';
import FormInputRow from 'components/FormInputRow/FormInputRow';
import { useAppContext } from 'context/appContext';
import {
  Container, FormTitle, Form, StyledButton as Button, MemberSwitchContainer,
} from './page.styles';

function RegisterPage() {
  const [isLogin, setIsLogin] = useState(false);
  const [formValues, setFormValues] = useState({
    name: '',
    email: '',
    password: '',
  });

  const { setupUser } = useAppContext();

  const handleOnSubmit = (event) => {
    event.preventDefault();
    const { name, email, password } = formValues;
    console.log({ email });
    console.log({ password });

    if (!email || !password) {
      alert('Please fill out all fields');
      return;
    }
    const currentUser = { name, email, password };
    if (isLogin) {
      setupUser({
        currentUser,
        endPoint: 'login',
      });
    } else {
      setupUser({
        currentUser,
        endPoint: 'register',
      });
    }
  };

  const handleOnChange = (event) => {
    setFormValues({
      ...formValues,
      [event.target.name]: event.target.value,
    });
  };
  return (
    <Container>
      <Card>
        <Logo />
        <FormTitle>Register</FormTitle>
        <Form onSubmit={handleOnSubmit}>
          {!isLogin && <FormInputRow onChange={handleOnChange} type="text" name="name" />}
          <FormInputRow onChange={handleOnChange} type="text" name="email" />
          <FormInputRow onChange={handleOnChange} type="password" name="password" />
          <Button type="submit">Submit</Button>
        </Form>
        <Button variant="secondary">Demo App</Button>
        <MemberSwitchContainer>
          Already a memeber?
          <Button
            variant="text"
            onClick={() => setIsLogin((prev) => !prev)}
          >
            {isLogin ? 'Register' : 'Login'}
          </Button>
        </MemberSwitchContainer>
      </Card>
    </Container>
  );
}

export default RegisterPage;
