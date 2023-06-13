import styled from 'styled-components';

export const StyledButton = styled.button`
  background-color: ${(props) => props.theme.colors.primary};
  color: white;
  border: none;
  padding: 8px 20px;
  border-radius: ${(props) => props.theme.borderRadius};
  cursor: pointer;
  transition: background-color 0.2s;

  &:hover {
    background-color: #0e7c86;
  }
`;
