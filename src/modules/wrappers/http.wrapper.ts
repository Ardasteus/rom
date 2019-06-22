import Axios from 'classes/axios.instance';
import { HttpMethod } from 'enums/http_method';
import { ApiEndpoint } from 'enums/api_endpoint';
import { RequestConfig } from 'interfaces/request_config.interface';

export class Http {
  public async request(method: HttpMethod, endpoint: ApiEndpoint, config: RequestConfig = {}) {
    const fullConfig: any = config;
    fullConfig.method = method;
    fullConfig.url = endpoint;

    return Axios.request(fullConfig);
  }
}
