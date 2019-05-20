import * as React from 'react';
import 'styles/HomePage.scss';
import { Redirect } from 'react-router-dom'
import Button from '@material-ui/core/Button';
import { Card } from '@material-ui/core';
import NavBar from './NavBar'

class HomePage extends React.Component {

  render() {
    return (
      <div className='home-page'>
        <NavBar />
        <img src={'public/images/homepage-background.png'} className='bg' />       
      </div>
    );
  }
}

export default HomePage;