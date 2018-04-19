// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

package consul;

import ballerina/io;
import ballerina/mime;

public function ConsulConnector::getService (string serviceName) returns CatalogService[]|ConsulError {
    endpoint http:Client clientEndpoint = self.clientEndpoint;
    ConsulError consulError = {};
    string consulPath = "/v1/catalog/service/" + serviceName;

    http:Request request;
    if (self.aclToken != "") {
        request.setHeader("X-Consul-Token", self.aclToken);
    }

    var httpResponse = clientEndpoint -> get(consulPath, request);
    CatalogService[] serviceResponse = [];

    match httpResponse {
        http:HttpConnectorError err => { consulError.message = err.message;
                                         consulError.cause = err.cause;
                                         consulError.statusCode = err.statusCode;
                                         return consulError;
        }
        http:Response response => { int statusCode = response.statusCode;
                                    var consulJSONResponse = response.getJsonPayload();
                                    match consulJSONResponse {
                                        mime:EntityError err => {
                                            consulError.message = err.message;
                                            consulError.cause = err.cause;
                                            return consulError;
                                        }
                                        json jsonResponse => {
                                            if (statusCode == 200) {
                                                serviceResponse = convertToCatalogServices(jsonResponse);
                                                return serviceResponse;
                                            } else {
                                                consulError.message = jsonResponse.errors[0].message.toString();
                                            consulError.statusCode = statusCode;
                                            return consulError;
                                            }
                                        }
                                    }
        }
    }
}

public function ConsulConnector::getCheckByState (string state) returns HealthCheck[]|
                                                                        ConsulError {
    endpoint http:Client clientEndpoint = self.clientEndpoint;
    ConsulError consulError = {};
    string consulPath = "/v1/health/state/" + state;

    http:Request request;
    if (self.aclToken != "") {
        request.setHeader("X-Consul-Token", self.aclToken);
    }

    var httpResponse = clientEndpoint -> get(consulPath, request);
    HealthCheck[] checkResponse = [];

    match httpResponse {
        http:HttpConnectorError err => { consulError.message = err.message;
                                         consulError.cause = err.cause;
                                         consulError.statusCode = err.statusCode;
                                         return consulError;
        }
        http:Response response => { int statusCode = response.statusCode;
                                    var consulJSONResponse = response.getJsonPayload();
                                    match consulJSONResponse {
                                        mime:EntityError err => {
                                            consulError.message = err.message;
                                            consulError.cause = err.cause;
                                            return consulError;
                                        }
                                        json jsonResponse => {
                                            if (statusCode == 200) {
                                                checkResponse = convertToHealthClients(jsonResponse);
                                                return checkResponse;
                                            } else {
                                                consulError.message = jsonResponse.error.message.toString();
                                                consulError.statusCode = statusCode;
                                                return consulError;
                                            }
                                        }
                                    }
        }
    }
}

public function ConsulConnector::readKey (string key) returns Value[]|
                                                              ConsulError {
    endpoint http:Client clientEndpoint = self.clientEndpoint;
    ConsulError consulError = {};
    string consulPath = "/v1/kv/" + key;

    http:Request request;
    if (self.aclToken != "") {
        request.setHeader("X-Consul-Token", self.aclToken);
    }

    var httpResponse = clientEndpoint -> get(consulPath, request);
    Value[] keyResponse = [];

    match httpResponse {
        http:HttpConnectorError err => { consulError.message = err.message;
                                         consulError.cause = err.cause;
                                         consulError.statusCode = err.statusCode;
                                         return consulError;
        }
        http:Response response => { int statusCode = response.statusCode;
                                    var consulJSONResponse = response.getJsonPayload();
                                    match consulJSONResponse {
                                        mime:EntityError err => {
                                            consulError.message = err.message;
                                            consulError.cause = err.cause;
                                            return consulError;
                                        }
                                        json jsonResponse => {
                                            if (statusCode == 200) {
                                                keyResponse = convertToValues(jsonResponse);
                                                return keyResponse;
                                            } else {
                                                consulError.message = jsonResponse.error.message.toString();
                                            consulError.statusCode = statusCode;
                                            return consulError;
                                            }
                                        }
                                    }
        }
    }
}

public function ConsulConnector::registerService (json jsonPayload) returns boolean|
                                                                            ConsulError {
    endpoint http:Client clientEndpoint = self.clientEndpoint;
    ConsulError consulError = {};
    string consulPath = "/v1/agent/service/register";

    http:Request request;
    if (self.aclToken != "") {
        request.setHeader("X-Consul-Token", self.aclToken);
    }
    request.setJsonPayload(jsonPayload);
    var httpResponse = clientEndpoint -> put(consulPath, request);

    match httpResponse {
        http:HttpConnectorError err => { consulError.message = err.message;
                                         consulError.cause = err.cause;
                                         consulError.statusCode = err.statusCode;
                                         return consulError;
        }
        http:Response response => { int statusCode = response.statusCode;
                                    if (statusCode == 200) {
                                        return true;
                                    } else {
                                        var consulStringResponse = response.getStringPayload();
                                        match consulStringResponse {
                                            http:PayloadError err => {
                                                consulError.message = err.message;
                                                consulError.cause = err.cause;
                                                return consulError;
                                            }
                                            string stringResponse => {
                                                consulError.message = stringResponse;
                                                consulError.statusCode = statusCode;
                                                return consulError;
                                            }
                                        }
                                    }
        }

    }
}

public function ConsulConnector::registerCheck (json jsonPayload) returns boolean|
                                                                          ConsulError {
    endpoint http:Client clientEndpoint = self.clientEndpoint;
    ConsulError consulError = {};
    string consulPath = "/v1/agent/check/register";

    http:Request request;
    if (self.aclToken != "") {
        request.setHeader("X-Consul-Token", self.aclToken);
    }
    request.setJsonPayload(jsonPayload);
    var httpResponse = clientEndpoint -> put(consulPath, request);

    match httpResponse {
        http:HttpConnectorError err => { consulError.message = err.message;
                                         consulError.cause = err.cause;
                                         consulError.statusCode = err.statusCode;
                                         return consulError;
        }
        http:Response response => { int statusCode = response.statusCode;
                                    if (statusCode == 200) {
                                        return true;
                                    } else {
                                        var consulStringResponse = response.getStringPayload();
                                        match consulStringResponse {
                                            http:PayloadError err => {
                                                consulError.message = err.message;
                                                consulError.cause = err.cause;
                                                return consulError;
                                            }
                                            string stringResponse => {
                                                consulError.message = stringResponse;
                                                consulError.statusCode = statusCode;
                                                return consulError;
                                            }
                                        }
                                    }
        }
    }
}

public function ConsulConnector::createKey (string keyName, string value) returns boolean|
                                                                                  ConsulError {
    endpoint http:Client clientEndpoint = self.clientEndpoint;
    ConsulError consulError = {};
    string consulPath = "/v1/kv/" + keyName;

    http:Request request;
    if (self.aclToken != "") {
        request.setHeader("X-Consul-Token", self.aclToken);
    }
    request.setJsonPayload(value);
    var httpResponse = clientEndpoint -> put(consulPath, request);

    match httpResponse {
        http:HttpConnectorError err => { consulError.message = err.message;
                                         consulError.cause = err.cause;
                                         consulError.statusCode = err.statusCode;
                                         return consulError;
        }
        http:Response response => { int statusCode = response.statusCode;
                                    if (statusCode == 200) {
                                        return true;
                                    } else {
                                        var consulStringResponse = response.getStringPayload();
                                        match consulStringResponse {
                                            http:PayloadError err => {
                                                consulError.message = err.message;
                                                consulError.cause = err.cause;
                                                return consulError;
                                            }
                                            string stringResponse => {
                                                consulError.message = stringResponse;
                                                consulError.statusCode = statusCode;
                                                return consulError;
                                            }
                                        }
                                    }
        }
    }
}
