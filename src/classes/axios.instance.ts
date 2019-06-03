import axios from 'axios';

/**
 * Instance of axios with `baseURL` set to API that should be used to make http requests
 */
const instance = axios.create({
  baseURL: `${process.env.API_URL}:${process.env.API_PORT}/${process.env.API_PATH}`,
});

export default instance;
