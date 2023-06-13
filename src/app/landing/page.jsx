'use client';

import Image from 'next/image';
import { Container } from './page.styles';
import { Navigation } from '../../components/Navigation/Navigation.styles';
import Hero from '../../components/Hero/Hero';

function LandingPage() {
  return (
    <Container>
      <Navigation>
        <Image
          src="./logo.svg"
          width={164}
          height={50}
          alt="Picture of the author"
        />
      </Navigation>
      <Hero />
    </Container>
  );
}

export default LandingPage;
