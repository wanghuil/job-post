'use client';

import { useAppContext } from 'context/appContext';
import RedirectTemplate from 'components/RedirectTemplate/RedirectTemplate';

function DashboardPage() {
  const context = useAppContext();
  console.log(context);
  // if (user === undefined) {
  //   return (<RedirectTemplate />);
  // }

  return (
    <h1>Dashboard</h1>
  );
}

export default DashboardPage;
