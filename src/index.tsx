import * as React from "react";
import * as ReactDOM from "react-dom";

import App from "components/App";

require('dotenv').config();

console.log(process.env.API_URL);

ReactDOM.render(<App />, document.getElementById('root'));