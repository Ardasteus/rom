import * as React from 'react';
import * as ReactDOM from 'react-dom';

import App from 'components/App';

import dotenv = require('dotenv');
dotenv.config();

ReactDOM.render(<App />, document.getElementById('root'));
