import * as React from 'react';
import 'styles/HomePage.scss';
import NavBar from './NavBar';

class HomePage extends React.Component {

  render() {
    return (
      <div className='home-page'>
        <NavBar />
        <img src={'public/images/homepage-background.jpg'} className='bg' />
      </div>
    );
  }
}

export default HomePage;
